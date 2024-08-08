import 'package:heathbridge_lao/package.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 200,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: TextButton(
                    onPressed: () {
                      context.push("/signup");
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: ConstantColor.colorMain,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'ສ້າງບັນຊີຜູ້ໃຊ້ໃໝ່',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: TextButton(
                    onPressed: () {
                      context.push("/signin");
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: ConstantColor.colorMain),
                    ),
                    child: const Text(
                      'ໄປໜ້າຕໍ່ໄປ',
                      style: TextStyle(color: ConstantColor.colorMain),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
