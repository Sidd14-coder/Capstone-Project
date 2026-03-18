// import 'package:flutter/material.dart';
// import '../../services/emi_payment_service.dart';
// import 'package:intl/intl.dart';

// class PaymentHistoryScreen extends StatelessWidget {
//   const PaymentHistoryScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Payment History"),
//       ),

//       body: emiPayments.isEmpty
//           ? const Center(
//               child: Text("No EMI payments yet"),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: emiPayments.length,
//               itemBuilder: (context, index) {

//                 final payment = emiPayments[index];

//                 return Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),

//                   child: ListTile(

//                     leading: const Icon(
//                       Icons.payment,
//                       color: Colors.green,
//                     ),

//                     title: Text(payment.emiName),

//                     subtitle: Text(
//                       DateFormat('d MMM yyyy')
//                           .format(payment.date),
//                     ),

//                     trailing: Text(
//                       "₹${payment.amount}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    var box = Hive.box('paymentHistory');
    var payments = box.values.toList(); // ✅ ADD THIS

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
      ),

      body: payments.isEmpty   // ✅ BODY ADD KIYA
          ? const Center(
              child: Text("No EMI payments yet"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) {

                final payment = payments[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: ListTile(
                    leading: const Icon(
                      Icons.payment,
                      color: Colors.green,
                    ),

                    title: Text(payment['name']),

                    subtitle: Text(
                      DateFormat('d MMM yyyy')
                          .format(DateTime.parse(payment['date'])),
                    ),

                    trailing: Text(
                      "₹${payment['amount']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}