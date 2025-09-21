import 'package:flutter/material.dart';
import 'package:saru/generated/l10n.dart';

class FulfillmentStatusMapper {
  static Map<String, dynamic> mapOrderStatus({
    required String? financialStatus,
    required String? fulfillmentStatus,
  }) {
    final fStatus = financialStatus?.trim().toUpperCase();
    final flStatus = fulfillmentStatus?.trim().toUpperCase();

    // 1️⃣ Financial status mapping
    switch (fStatus) {
      case "REFUNDED":
        return {"label": S.current.refunded, "color": Colors.red};
      case "PARTIALLY_REFUNDED":
        return {"label": S.current.partiallyRefunded, "color": Colors.purple};
      case "VOIDED":
        return {"label": S.current.voided, "color": Colors.grey};
      case "AUTHORIZED":
        return {"label": S.current.authorized, "color": Colors.blue};
      case "PARTIALLY_PAID":
        return {"label": S.current.partiallyPaid, "color": Colors.orange};
      case "PENDING":
        return {"label": S.current.pending, "color": Colors.orange};
      case "PAID":
        // continue to fulfillment status mapping
        break;
      default:
        // if financialStatus is null, check fulfillment
        break;
    }

    // 2️⃣ Fulfillment status mapping
    switch (flStatus) {
      case "FULFILLED":
        return {"label": S.current.fulfilled, "color": Colors.green};
      case "PARTIALLY_FULFILLED":
        return {"label": S.current.partiallyFulfilled, "color": Colors.orange};
      case "IN_PROGRESS":
      case "PENDING_FULFILLMENT": // deprecated
        return {"label": S.current.inProgress, "color": Colors.orange};
      case "ON_HOLD":
        return {"label": S.current.onHold, "color": Colors.red};
      case "UNFULFILLED":
      case "OPEN": // deprecated
        return {"label": S.current.unfulfilled, "color": Colors.red};
      case "RESTOCKED":
        return {"label": S.current.restocked, "color": Colors.grey};
      case "SCHEDULED":
        return {"label": S.current.scheduled, "color": Colors.blue};
      default:
        return {"label": S.current.unknown, "color": Colors.black};
    }
  }

  Map<String, Map<String, dynamic>> financialStatusMap = {
    "AUTHORIZED": {
      "label": S.current.authorized,
      "color": Colors.blue, // payment authorized but not captured
    },
    "PAID": {
      "label": S.current.paid,
      "color": Colors.green, // payment completed
    },
    "PARTIALLY_PAID": {
      "label": S.current.partiallyPaid,
      "color": Colors.orange, // partial payment received
    },
    "PARTIALLY_REFUNDED": {
      "label": S.current.partiallyRefunded,
      "color": Colors.purple, // partial refund applied
    },
    "REFUNDED": {
      "label": S.current.refunded,
      "color": Colors.red, // fully refunded
    },
    "PENDING": {
      "label": S.current.pending,
      "color": Colors.orange, // payment pending
    },
    "VOIDED": {
      "label": S.current.voided,
      "color": Colors.grey, // payment voided/cancelled
    },
  };
}
