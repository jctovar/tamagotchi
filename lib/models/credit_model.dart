class CreditModel {
  CreditModel({
    required this.creditId,
    required this.creditName,
    required this.creditMembers,
  });

  final int creditId;
  final String creditName;
  final String creditMembers;

  factory CreditModel.fromJson(Map<String, dynamic> json) => CreditModel(
    creditId: json["credit_id"],
    creditName: json["credit_name"],
    creditMembers: json["credit_members"],
  );

  Map<String, dynamic> toJson() => {
    "credit_id": creditId,
    "credit_name": creditName,
    "credit_members": creditMembers,
  };
}