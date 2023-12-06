import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/shared/domain/models/chat/user_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';

class Avatar extends ConsumerWidget {
  final User user;
  final double size;
  final bool shadow;
  final bool? badge;

  const Avatar(this.user, this.size, this.shadow, {this.badge, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String strBadge = badge == null
        ? ""
        : (user.unReadCount != 0 ? user.unReadCount.toString() : "");
    double nPadding = badge == null ? 6.5 : (user.unReadCount != 0 ? 5 : 6.5);
    Color color = Colors.white,
        avatarBack = user.color == 'null'
            ? AppColors.primary
            : getColorFromString(user.color);

    if (user.status == Status.online) {
      color = const Color(0xFF00CB66);
    } else if (user.status == Status.away) {
      color = const Color(0xFFFF9127);
    } else if (user.status == Status.onbreak) {
      color = const Color(0xFFFF9127);
    } else if (user.status == Status.oncall) {
      color = const Color(0xFFFF3535);
    }

    Widget renderAvatar;

    if (user.type == 'user') {
      if (user.avatar.startsWith('http') == false) {
        renderAvatar = CircleAvatar(
            foregroundColor: AppColors.white,
            backgroundColor: avatarBack,
            radius: size,
            child: Text(minimizeName(user.name),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white)));
      } else {
        renderAvatar = CircleAvatar(
            foregroundColor: AppColors.white,
            backgroundColor: Colors.transparent,
            radius: size,
            backgroundImage: NetworkImage(user.avatar));
      }
    } else {
      renderAvatar = CircleAvatar(
          foregroundColor: AppColors.white,
          backgroundColor: avatarBack,
          radius: size,
          child: const Icon(Icons.groups, color: AppColors.white, size: 28));
    }

    return Stack(
      children: [
        Container(
          // decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     border: Border.all(color: Colors.blue, width: 0.0)),
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: renderAvatar,
        ),
        user.unReadCount < 0 || user.type == 'group'
            ? const SizedBox.shrink()
            : Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x60000000),
                            spreadRadius: 0,
                            blurRadius: 5,
                            offset: Offset(0, 5))
                      ]),
                  padding: EdgeInsets.only(left: nPadding, right: nPadding),
                  child: Text(strBadge,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.white)),
                ),
              )
      ],
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
      // } else
    }

    return AppColors.primary;
  }
}
