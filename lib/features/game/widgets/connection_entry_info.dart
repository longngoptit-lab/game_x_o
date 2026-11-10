import 'package:flutter/material.dart';

import 'package:game_x_o/utils/app_icons.dart';
import 'package:game_x_o/utils/extensions/build_context.dart';
import 'package:game_x_o/utils/extensions/num_extension.dart';
import 'package:game_x_o/commons/widgets/custom_image.dart';
import 'package:game_x_o/commons/widgets/custom_text.dart';
import 'package:game_x_o/commons/widgets/marquee.dart';
import 'package:game_x_o/features/game/models/matrix_size_model.dart';

// ConnectionScreen's entry-fee + game-mode summary bar.
class ConnectionEntryInfo extends StatelessWidget {
  final int fee;
  final MatrixSize size;

  const ConnectionEntryInfo({super.key, required this.fee, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105.r(context),
      width: context.screenWidth,
      padding: EdgeInsets.all(10.r(context)),
      decoration: BoxDecoration(
        border: Border.all(color: context.color.onSurface.withAlpha(150)),
        borderRadius: BorderRadius.circular(10.r(context)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                CustomText(
                  context.tr('earnCoins'),
                  fontSize: context.font.normal,
                  color: context.color.onSurface.withAlpha(100),
                ),
                Divider(color: context.color.outline, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImage(
                      AppIcons.coin,
                      width: 20.r(context),
                      height: 20.r(context),
                    ),
                    SizedBox(width: 6.r(context)),
                    CustomText(
                      fee.toString(),
                      fontSize: context.font.large,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.r(context)),
            width: 1,
            height: 77.r(context),
            color: context.color.outline,
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                CustomText(
                  context.tr('gameMode'),
                  fontSize: context.font.normal,
                  color: context.color.onSurface.withAlpha(100),
                ),
                Divider(color: context.color.outline, thickness: 1),
                Flexible(
                  child: MarqueeWidget(
                    child: CustomText(
                      size.title.toString(),
                      fontSize: context.font.large,
                      fontWeight: FontWeight.w600,
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
