class AddMoneyRequest {
  String? bankId = "";
  double? moneyAdd = 0.0;
  String? otp = "";

  AddMoneyRequest(this.bankId, this.moneyAdd, this.otp);
  AddMoneyRequest.buildDefault();
}


class TransferMoneyRequest {
  String? email = "";
  double? moneyAdd = 0.0;
  String? description = "";
  String? otp = "";

  TransferMoneyRequest(this.email, this.moneyAdd, this.description, this.otp);
  TransferMoneyRequest.buildDefault();
}