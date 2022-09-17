import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';

class AboutPassyDialog extends StatelessWidget {
  const AboutPassyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: SizedBox(
        width: 350,
        height: 350,
        child: ListView(
          children: [
            const SizedBox(height: 24),
            Center(
                child: SvgPicture.asset(
              'assets/images/logo.svg',
              color: Colors.purple,
              width: 128,
            )),
            const SizedBox(height: 24),
            const Text(
              'Passy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'FiraCode',
                color: PassyTheme.lightContentSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const PassyPadding(
              Text(
                'Store passwords, payment cards, notes, ID cards and identities offline and safe, synchronized between all of your devices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'FiraCode',
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Made with 💜 by Gleammer',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'FiraCode',
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
