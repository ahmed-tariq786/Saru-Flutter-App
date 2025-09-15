import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

Widget html(String htmlContent) {
  return Html(
    data: htmlContent,
    style: {
      "ul": Style(
        fontFamily: "Arial",
        margin: Margins.all(0), // remove default margin
        padding: HtmlPaddings.only(left: 16), // small left padding
      ),
      "li": Style(
        padding: HtmlPaddings.only(right: 5, left: 5), // padding on the right for RTL

        margin: Margins.only(
          left: 0,

          right: 0,
        ), // no extra left margin
        fontSize: FontSize(12),
        listStyleType: ListStyleType.disc, // ✅ ensures bullet appears
      ),
      "p": Style(
        fontFamily: "Arial",
        letterSpacing: 0.6,
        fontSize: FontSize(12),
      ),
      "h1": Style(
        fontFamily: "Arial",
        letterSpacing: 0.6,
        fontSize: FontSize(16),
        fontWeight: FontWeight.w900,
      ),
      "h2": Style(
        fontFamily: "Arial",
        letterSpacing: 0.6,
        fontSize: FontSize(16),
        fontWeight: FontWeight.w900,
      ),
      "h3": Style(
        fontFamily: "Arial",
        letterSpacing: 0.6,
        fontSize: FontSize(16),
        fontWeight: FontWeight.w900,
      ),
      "h4": Style(
        fontFamily: "Arial",
        letterSpacing: 0.6,
        fontSize: FontSize(16),
        fontWeight: FontWeight.w900,
      ),
      "h5": Style(
        fontFamily: "Arial",
        letterSpacing: 0.6,
        fontSize: FontSize(16),
        fontWeight: FontWeight.w900,
      ),
      "h6": Style(
        fontFamily: "Arial",
        letterSpacing: 0.6,
        fontSize: FontSize(16),
        fontWeight: FontWeight.w900,
      ),
    },
  );
}
