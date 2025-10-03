import 'package:flutter/material.dart';
import '../page-1/customer_support.dart';

class CustomerSupportButton extends StatelessWidget {
  final double fem;

  const CustomerSupportButton({required this.fem});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 25 * fem,
      right: 7 * fem,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SupportScreen()),
          );
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.headset_mic,
            color: Color(0xffe5195e),
            size: 30,
          ),
        ),
      ),
    );
  }
}