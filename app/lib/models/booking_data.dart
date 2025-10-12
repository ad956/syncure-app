class BookingData {
  final List<String> states;
  final List<String> cities;
  final List<String> hospitals;
  final List<String> diseases;

  BookingData({
    required this.states,
    required this.cities,
    required this.hospitals,
    required this.diseases,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      states: List<String>.from(json['states'] ?? []),
      cities: List<String>.from(json['cities'] ?? []),
      hospitals: List<String>.from(json['hospitals'] ?? []),
      diseases: List<String>.from(json['diseases'] ?? []),
    );
  }
}

class BookingSelection {
  String? state;
  String? city;
  String? hospital;
  String? disease;
  String? notes;

  bool get canProceedToCity => state != null;
  bool get canProceedToHospital => city != null;
  bool get canProceedToDisease => hospital != null;
  bool get canProceedToNotes => disease != null;
  bool get canProceedToPayment => notes != null && notes!.length >= 10;

  void reset() {
    state = null;
    city = null;
    hospital = null;
    disease = null;
    notes = null;
  }
}