class Receipt {
  final String bookingId;
  final String pnr;
  final String status;
  final DateTime bookingDate;
  final String flightNumber;
  final String departure;
  final String arrival;
  final DateTime departureTime;
  final String passengerName;
  final String email;
  final double totalAmount;
  final Map<String, int> extras;

  Receipt({
    required this.bookingId,
    required this.pnr,
    required this.status,
    required this.bookingDate,
    required this.flightNumber,
    required this.departure,
    required this.arrival,
    required this.departureTime,
    required this.passengerName,
    required this.email,
    required this.totalAmount,
    required this.extras,
  });
}
