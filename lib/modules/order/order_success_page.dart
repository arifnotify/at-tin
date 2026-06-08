import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';

class OrderSuccessPage
    extends StatelessWidget {

  const OrderSuccessPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      body: Center(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment
                  .center,

          children: [

            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 120,
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              "Order Placed Successfully",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            ElevatedButton(
              onPressed: () {

                Get.offAllNamed(AppRoutes.home);
              },
              child:
                  const Text(
                "Back To Home",
              ),
            ),
          ],
        ),
      ),
    );
  }
}