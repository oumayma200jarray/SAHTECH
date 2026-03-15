import 'package:flutter/material.dart';
//import 'package:stage/inscription.dart';
//import 'package:stage/connexion.dart';

Widget buttonIn(String text, VoidCallback onPressed, {double? width}) {
  return SizedBox(
    width: width,
    height: 55,
    child: ElevatedButton(
      onPressed: onPressed,
      clipBehavior: Clip.antiAlias,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
//child :image==null
//?Text('inscription',style: TextStyle(fontSize:10, fontWeight: FontWeight.bold ,))
//:Row(children:[image,Text('continuer avec google',style: TextStyle(fontSize:10, fontWeight: FontWeight.bold ,)),])),

Widget buttonC(
  String text,
  VoidCallback onPressed, {
  IconData? icon,
  double? width,
}) {
  return SizedBox(
    width: width,
    height: 55,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 13, 84, 242),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Center(
        child: icon == null
            ? Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}
