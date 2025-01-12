class UserDetails {
  String dietaryRestriction;
  String name;
  String preferredCuisine;
  String email;

  UserDetails({
    required this.dietaryRestriction,
    required this.name,
    required this.preferredCuisine,
    required this.email,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        dietaryRestriction: json["dietaryRestriction"],
        name: json["name"],
        preferredCuisine: json["preferredCuisine"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "dietaryRestriction": dietaryRestriction,
        "name": name,
        "preferredCuisine": preferredCuisine,
        "email": email,
      };
}
