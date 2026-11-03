using System.Collections;
using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Query;
using PFMPManager.Api.Data;
using PFMPManager.Api.Models;

namespace PFMPManager.Api.RegressionTests;

// No database provider is configured. Unexpected real EF access fails closed.
internal sealed class IsolatedDbContext : AppDbContext
{
    public List<TablePresence> WrittenPresences { get; } = [];
    public int SaveCalls { get; private set; }

    public IsolatedDbContext(DateTime start, IReadOnlyCollection<string> workingDays)
        : base(new DbContextOptionsBuilder<AppDbContext>().Options)
    {
        Etudier = new MemoryDbSet<Etudier>([
            new() { Id_Utilisateur = 1, Id_Etablissement = 2, Id_Classe = 3,
                AnneeRentree = start.Year, AnneeSortie = start.Year }
        ]);
        GroupeClasse = new MemoryDbSet<GroupeClasse>([
            new() { Id_Etablissement = 2, Id_Classe = 3, LibelleClasse = "Fixture" }
        ]);
        Filiere = new MemoryDbSet<Filiere>([]);
        Utilisateur = new MemoryDbSet<Utilisateur>([]);
        Organisation = new MemoryDbSet<Organisation>([]);
        Travailler = new MemoryDbSet<Travailler>([]);
        Professionnel = new MemoryDbSet<Professionnel>([]);
        Planning = new MemoryDbSet<Planning>([new() { Id_Planning = 4 }]);
        PlanningJours = new MemoryDbSet<PlanningJours>(workingDays.Select(day =>
            new PlanningJours { Id_Planning = 4, Jour = day }));
        TablePresence = new MemoryDbSet<TablePresence>([], WrittenPresences.AddRange);
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        SaveCalls++;
        return Task.FromResult(WrittenPresences.Count);
    }
}

internal sealed class MemoryDbSet<T> : DbSet<T>, IQueryable<T>, IAsyncEnumerable<T>
    where T : class
{
    private readonly IQueryable<T> _query;
    private readonly Action<IEnumerable<T>>? _captureWrites;

    public MemoryDbSet(IEnumerable<T> rows, Action<IEnumerable<T>>? captureWrites = null)
    {
        _query = new MemoryAsyncQuery<T>(rows);
        _captureWrites = captureWrites;
    }

    Type IQueryable.ElementType => _query.ElementType;
    public override Microsoft.EntityFrameworkCore.Metadata.IEntityType EntityType
        => throw new NotSupportedException("No EF model is configured in this fixture.");
    Expression IQueryable.Expression => _query.Expression;
    IQueryProvider IQueryable.Provider => new MemoryAsyncQueryProvider(_query.Provider);
    IEnumerator<T> IEnumerable<T>.GetEnumerator() => _query.GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => _query.GetEnumerator();

    public override IAsyncEnumerator<T> GetAsyncEnumerator(CancellationToken cancellationToken = default)
        => new MemoryAsyncEnumerator<T>(_query.GetEnumerator(), cancellationToken);

    public override void AddRange(IEnumerable<T> entities)
        => (_captureWrites ?? throw new InvalidOperationException("Unexpected write."))(entities);
}

internal sealed class MemoryAsyncQuery<T> : EnumerableQuery<T>, IAsyncEnumerable<T>, IQueryable<T>
{
    public MemoryAsyncQuery(IEnumerable<T> rows) : base(rows) { }
    public MemoryAsyncQuery(Expression expression) : base(expression) { }

    IQueryProvider IQueryable.Provider => new MemoryAsyncQueryProvider(this);

    public IAsyncEnumerator<T> GetAsyncEnumerator(CancellationToken cancellationToken = default)
        => new MemoryAsyncEnumerator<T>(this.AsEnumerable().GetEnumerator(), cancellationToken);
}

internal sealed class MemoryAsyncQueryProvider(IQueryProvider inner) : IAsyncQueryProvider
{
    public IQueryable CreateQuery(Expression expression)
        => throw new NotSupportedException("Non-generic queries are not used by this fixture.");

    public IQueryable<TElement> CreateQuery<TElement>(Expression expression)
        => new MemoryAsyncQuery<TElement>(expression);

    public object? Execute(Expression expression) => inner.Execute(expression);
    public TResult Execute<TResult>(Expression expression) => inner.Execute<TResult>(expression);

    public TResult ExecuteAsync<TResult>(Expression expression, CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var resultType = typeof(TResult).GetGenericArguments().Single();
        var execute = typeof(IQueryProvider).GetMethods()
            .Single(method => method.Name == nameof(Execute) && method.IsGenericMethod);
        var result = execute.MakeGenericMethod(resultType).Invoke(inner, [expression]);
        var completedTask = typeof(Task).GetMethod(nameof(Task.FromResult))!
            .MakeGenericMethod(resultType).Invoke(null, [result]);
        return (TResult)completedTask!;
    }
}

internal sealed class MemoryAsyncEnumerator<T>(IEnumerator<T> inner, CancellationToken cancellationToken)
    : IAsyncEnumerator<T>
{
    public T Current => inner.Current;
    public ValueTask<bool> MoveNextAsync()
    {
        cancellationToken.ThrowIfCancellationRequested();
        return ValueTask.FromResult(inner.MoveNext());
    }

    public ValueTask DisposeAsync()
    {
        inner.Dispose();
        return ValueTask.CompletedTask;
    }
}
