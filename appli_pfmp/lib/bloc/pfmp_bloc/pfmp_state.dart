import 'package:appli_pfmp/model/pfmp.dart';
import 'package:appli_pfmp/model/pfmp_creation_receipt.dart';

class PfmpState {
  const PfmpState();
}

class PfmpInitializeState extends PfmpState {
  const PfmpInitializeState();
}

class PfmpLoadingState extends PfmpState {
  const PfmpLoadingState();
}

class PfmpSuccessState extends PfmpState {
  final List<Pfmp?> pfmp;
  const PfmpSuccessState(this.pfmp);
}

class PfmpErrorState extends PfmpState {
  final Object error;
  const PfmpErrorState(this.error);
}

class PfmpPostLoadingState extends PfmpState {
  const PfmpPostLoadingState();
}

class PfmpPostSuccessState extends PfmpState {
  final PfmpCreationReceipt nouvelleEntree;
  const PfmpPostSuccessState(this.nouvelleEntree);
}

class PfmpPostErrorState extends PfmpState {
  final Object error;
  final bool outcomeUnknown;
  const PfmpPostErrorState(this.error, {this.outcomeUnknown = false});
}

class PfmpReloadErrorState extends PfmpState {
  final PfmpCreationReceipt receipt;
  const PfmpReloadErrorState(this.receipt);
}
