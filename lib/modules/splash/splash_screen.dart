import 'package:flutter/material.dart';

class SplashScreen
    extends StatelessWidget {

  const SplashScreen({
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
              Icons.store,
              size: 90,
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              "at tin",
              style:
                  TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight
                        .bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}