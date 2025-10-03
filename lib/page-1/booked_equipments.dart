import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingDetailScreen({Key? key, required this.bookingData}) : super(key: key);

  List<String> parseJsonList(String jsonString) {
    try {
      final List<dynamic> parsed = json.decode(jsonString);
      return parsed.map((e) => e?.toString() ?? 'N/A').toList();
    } catch (e) {
      return ['Error parsing data'];
    }
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          content,
        ],
      ),
    );
  }

  Widget _buildEquipmentList() {
    final items = parseJsonList(bookingData['item_names']);
    final quantities = parseJsonList(bookingData['quantities']);
    final prices = parseJsonList(bookingData['per_unit_price']);

    return Card(color: Color(0xFF292938),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            items.length,
                (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(items[index],style: TextStyle(fontSize: 18,fontWeight:FontWeight.w600,
                        color: Colors.white),),
                  ),
                  Expanded(
                    child: Text('Qty: ${quantities[index]}',style: TextStyle(fontSize: 18,fontWeight:FontWeight.w600,
                        color: Colors.white),),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    return Scaffold(backgroundColor:  Color(0xFF121217),
      appBar: AppBar(
        title: const Text('Booking Details',style: TextStyle(fontSize: 22,fontWeight:FontWeight.w600,
        color: Colors.white),),
        backgroundColor:  Color(0xFF121217),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Details Section
              _buildSection(
                'Event Details',
                Card(color: Color(0xFF292938),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22,22,42,22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${bookingData['category']}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),),
                        const SizedBox(height: 8),
                        Text('Audience Size: ${bookingData['audience_size']}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),),
                        const SizedBox(height: 8),
                        Text('Duration: ${bookingData['duration']}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),),
                      ],
                    ),
                  ),
                ),
              ),

              // Time & Location Section
              _buildSection(
                'Time & Location',
                Card(color: Color(0xFF292938),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${formatter.format(DateTime.parse(bookingData['booking_date']))}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),),
                        const SizedBox(height: 8),
                        Text('Time: ${timeFormatter.format(DateTime.parse("2024-01-01 ${bookingData['booked_from']}"))} - '
                            '${timeFormatter.format(DateTime.parse("2024-01-01 ${bookingData['booked_to']}"))}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),),
                        const SizedBox(height: 8),
                        Text('Location: ${bookingData['location']}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),),
                      ],
                    ),
                  ),
                ),
              ),

              // Equipment Section
              _buildSection(
                'Equipment Details',
                _buildEquipmentList(),
              ),

              // Price Section
              _buildSection(
                'Pricing',
                Card(color: Color(0xFF292938),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        Text(
                          '${bookingData['total_price']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Special Request Section
              if (bookingData['special_request'] != 'no')
                _buildSection(
                  'Special Request',
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Text(bookingData['special_request'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}