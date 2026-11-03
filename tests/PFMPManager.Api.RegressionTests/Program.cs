using System.Reflection;
using System.Runtime.ExceptionServices;
using PFMPManager.Api.Controllers;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Helpers;
using PFMPManager.Api.RegressionTests;

// Package-free executable regression suite. Invokes production code without starting the API.
var cases = new (string Name, DateTime Start, DateTime End, string[] Days, DateTime[] Expected)[]
{
    ("maximum date included", new(9999, 12, 31), new(9999, 12, 31),
        ["Vendredi"], [new(9999, 12, 31)]),
    ("maximum date excluded by planning", new(9999, 12, 31), new(9999, 12, 31),
        ["Lundi"], []),
    ("maximum date reached after multiple days", new(9999, 12, 29), new(9999, 12, 31),
        ["Mercredi", "Vendredi"], [new(9999, 12, 29), new(9999, 12, 31)]),
    ("ordinary same-day period", new(2027, 1, 11), new(2027, 1, 11),
        ["Lundi"], [new(2027, 1, 11)]),
    ("ordinary multiweek inclusive period", new(2027, 1, 4), new(2027, 1, 18),
        ["Lundi", "Vendredi"],
        [new(2027, 1, 4), new(2027, 1, 8), new(2027, 1, 11), new(2027, 1, 15), new(2027, 1, 18)]),
    ("leap day included", new(2028, 2, 28), new(2028, 3, 1),
        ["Mardi"], [new(2028, 2, 29)]),
    ("year boundary and date-only comparison", new(2026, 12, 31, 23, 45, 0), new(2027, 1, 1, 1, 0, 0),
        ["Jeudi", "Vendredi"], [new(2026, 12, 31), new(2027, 1, 1)]),
};

var failed = 0;
var passed = 0;
foreach (var test in cases)
{
    await Run($"attendance: {test.Name}", async () =>
    {
        using var context = new IsolatedDbContext(test.Start, test.Days);
        // These services are not used by the isolated attendance method.
        var controller = new PfmpController(context, null!, null!, null!);
        var method = typeof(PfmpController).GetMethod("CreatePresenceRowsForPfmpAsync",
            BindingFlags.Instance | BindingFlags.NonPublic)
            ?? throw new InvalidOperationException("Production attendance method was not found.");
        var planning = test.Days.Select(day => new CreatePlanningJoursDto { Jour = day }).ToList();
        await InvokeAttendance(method, controller, [1, test.Start, test.End, planning]);

        Equal(test.Expected, context.WrittenPresences.Select(row => row.DateJour!.Value).ToArray(),
            "attendance dates");
        Check(context.SaveCalls == 1, "Attendance must be saved exactly once.");
        Check(context.WrittenPresences.All(row => row.Id_Utilisateur == 1
            && row.Etat == "NON_RENSEIGNE" && row.Retard == 0 && !row.Justification),
            "Attendance defaults or student ownership changed.");
    });

    await Run($"administrator statistics: {test.Name}", async () =>
    {
        using var context = new IsolatedDbContext(test.Start, test.Days);
        var pfmp = new PfmpDto
        {
            DateDebut = test.Start, DateFin = test.End, IdEtudiant = 1,
            Id_Planning = 4, IdPfmp = 5, SIRET = "fixture"
        };
        var rows = await AdminListHelper.CreateList(context, [pfmp], [2]);
        Check(rows.Count == 1, "Synthetic enrollment must reach the statistics calculation.");
        Check(rows[0].Restants == test.Expected.Length,
            $"Expected {test.Expected.Length} working days, got {rows[0].Restants}.");
        Check(rows[0].Presence == 0 && rows[0].Absence == 0 && !rows[0].Status,
            "Unexpected attendance or completion state.");
        Check(context.SaveCalls == 0 && context.WrittenPresences.Count == 0,
            "Reading statistics must not write attendance.");
    });
}

Console.WriteLine($"RESULT: {passed} passed, {failed} failed, {passed + failed} total");
return failed == 0 ? 0 : 1;

async Task Run(string name, Func<Task> test)
{
    try
    {
        await test();
        passed++;
        Console.WriteLine($"PASS {name}");
    }
    catch (Exception error)
    {
        failed++;
        Console.WriteLine($"FAIL {name}: {error.GetType().Name}: {error.Message}");
        Console.WriteLine(error.StackTrace);
    }
}

static async Task InvokeAttendance(MethodInfo method, object target, object[] arguments)
{
    try
    {
        await (Task)method.Invoke(target, arguments)!;
    }
    catch (TargetInvocationException error) when (error.InnerException != null)
    {
        ExceptionDispatchInfo.Capture(error.InnerException).Throw();
        throw;
    }
}

static void Check(bool condition, string message)
{
    if (!condition) throw new InvalidOperationException(message);
}

static void Equal(DateTime[] expected, DateTime[] actual, string message)
{
    Check(expected.SequenceEqual(actual),
        $"Incorrect {message}: expected [{string.Join(", ", expected.Select(date => date.ToString("yyyy-MM-dd")))}], "
        + $"got [{string.Join(", ", actual.Select(date => date.ToString("yyyy-MM-dd")))}].");
}
