import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/features/timer/presentation/providers/timer_state_provider.dart';
import 'package:mplos_chat/shared/domain/models/timer/company_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';

// ignore: must_be_immutable
class CompanyItem extends ConsumerStatefulWidget {
  Company company;
  CompanyItem(this.company, {super.key});

  @override
  ConsumerState<CompanyItem> createState() => _CompanyItemState();
}

class _CompanyItemState extends ConsumerState<CompanyItem> {
  Company get company => widget.company;

  void handleSelectCompany() {
  }

  @override
  Widget build(BuildContext context) {
    Widget? renderAvatar;
    if (company.userProfile == "null") {
      renderAvatar = CircleAvatar(
        foregroundColor: AppColors.white,
        backgroundColor: getColorFromString(company.userColor),
        radius: 20,
        child: Text(minimizeName(company.userName),
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.white)),
      );
    } else {
      renderAvatar = CircleAvatar(
          foregroundColor: AppColors.white,
          backgroundColor: Colors.transparent,
          radius: 20,
          backgroundImage: NetworkImage(company.userProfile));
    }

    bool isSelected =
        ref.watch(timerStateNotifierProvider).activeCompany == company;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Badge.count(
            count: company.unreadMsgCount,
            isLabelVisible: company.unreadMsgCount != 0,
            textColor: Colors.white,
            child: renderAvatar),
        const SizedBox(width: 12.0),
        SizedBox(
          width: 100,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(company.name,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
            const SizedBox(height: 4.0),
            company.permission != 'null'
                ? Text(company.permission,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal))
                : const SizedBox.shrink(),
          ]),
        ),
        Icon(Icons.check, color: isSelected ? Colors.green : Colors.white)
      ]),
    );
  }

  String minimizeName(String name) {
    if (name.isEmpty) return "";

    final arr = name.toUpperCase().split(" ");
    return arr.length > 2
        ? "${arr[0].characters.first}${arr[1].characters.first}"
        : "${arr[0].characters.first}${arr[0].characters.toList()[1]}";
  }

  Color getColorFromString(String colorString) {
    if (colorString.startsWith('rgba')) {
      List<String> rgbaValues =
          colorString.replaceAll('rgba(', '').replaceAll(')', '').split(',');

      int red = int.parse(rgbaValues[0].trim());
      int green = int.parse(rgbaValues[1].trim());
      int blue = int.parse(rgbaValues[2].trim());
      double alpha = double.parse(rgbaValues[3].trim());

      return Color.fromARGB((alpha * 255).toInt(), red, green, blue);
    } else if (colorString.startsWith('rgb')) {
      List<String> rgbValues =
          colorString.replaceAll('rgb(', '').replaceAll(')', '').split(',');

      int red = int.parse(rgbValues[0].trim());
      int green = int.parse(rgbValues[1].trim());
      int blue = int.parse(rgbValues[2].trim());

      return Color.fromRGBO(red, green, blue, 1);
    } else if (colorString.startsWith("#")) {
      return Color(
          0xff000000 + int.parse(colorString.replaceAll('#', ''), radix: 16));
    }

    return AppColors.primary;
  }
}
