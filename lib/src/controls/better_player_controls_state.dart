// Dart imports:
import 'dart:io';
import 'dart:math';

// Project imports:
import 'package:better_player/better_player.dart';
import 'package:better_player/src/asms/better_player_asms_audio_track.dart';
import 'package:better_player/src/asms/better_player_asms_track.dart';
import 'package:better_player/src/controls/better_player_clickable_widget.dart';
import 'package:better_player/src/core/better_player_utils.dart';
import 'package:better_player/src/customizations/better_player_material_clickable_focus_widget.dart';
import 'package:better_player/src/video_player/video_player.dart';

// Flutter imports:
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///Base class for both material and cupertino controls
abstract class BetterPlayerControlsState<T extends StatefulWidget>
    extends State<T> {
  ///Min. time of buffered video to hide loading timer (in milliseconds)
  static const int _bufferingInterval = 20000;

  BetterPlayerController? get betterPlayerController;

  BetterPlayerControlsConfiguration get betterPlayerControlsConfiguration;

  VideoPlayerValue? get latestValue;

  void cancelAndRestartTimer();

  bool isVideoFinished(VideoPlayerValue? videoPlayerValue) {
    return videoPlayerValue?.position != null &&
        videoPlayerValue?.duration != null &&
        videoPlayerValue!.position.inMilliseconds != 0 &&
        videoPlayerValue.duration!.inMilliseconds != 0 &&
        videoPlayerValue.position >= videoPlayerValue.duration!;
  }

  void skipBack() {
    cancelAndRestartTimer();
    final beginning = const Duration().inMilliseconds;
    final skip = (latestValue!.position -
            Duration(
                milliseconds: betterPlayerControlsConfiguration
                    .backwardSkipTimeInMilliseconds))
        .inMilliseconds;
    betterPlayerController!
        .seekTo(Duration(milliseconds: max(skip, beginning)));
  }

  void skipForward() {
    cancelAndRestartTimer();
    final end = latestValue!.duration!.inMilliseconds;
    final skip = (latestValue!.position +
            Duration(
                milliseconds: betterPlayerControlsConfiguration
                    .forwardSkipTimeInMilliseconds))
        .inMilliseconds;
    betterPlayerController!.seekTo(Duration(milliseconds: min(skip, end)));
  }

  void onShowMoreClicked() {
    _showModalBottomSheet([_buildMoreOptionsList()]);
  }

  Widget _buildMoreOptionsList() {
    final translations = betterPlayerController!.translations;
    return SingleChildScrollView(
      // ignore: avoid_unnecessary_containers
      child: Focus(
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            if (betterPlayerControlsConfiguration.enablePlaybackSpeed)
              // ListTile(
              //   autofocus: true,
              //   leading: Icon(
              //     betterPlayerControlsConfiguration.playbackSpeedIcon,
              //     color: betterPlayerControlsConfiguration.overflowMenuIconsColor,
              //   ),
              //   title: Text(
              //     translations.overflowMenuPlaybackSpeed,
              //     style: _getOverflowMenuElementTextStyle(false),
              //   ),
              //   focusColor: Colors.blue,
              //   onTap: () {
              //     Navigator.of(context).pop();
              //     _showSpeedChooserWidget();
              //   },
              // ),
              _buildMoreOptionsListRow(
                  betterPlayerControlsConfiguration.playbackSpeedIcon,
                  translations.overflowMenuPlaybackSpeed, () {
                  Navigator.of(context).pop();
                  _showSpeedChooserWidget();
                }, true),
            if (betterPlayerControlsConfiguration.enableSubtitles)
              // ListTile(
              //   leading: Icon(
              //     betterPlayerControlsConfiguration.subtitlesIcon,
              //     color: betterPlayerControlsConfiguration.overflowMenuIconsColor,
              //   ),
              //   title: Text(
              //     translations.overflowMenuSubtitles,
              //     style: _getOverflowMenuElementTextStyle(false),
              //   ),
              //   focusColor: Colors.blue,
              //   onTap: () {
              //     Navigator.of(context).pop();
              //     _showSubtitlesSelectionWidget();
              //   },
              // ),
              _buildMoreOptionsListRow(
                  betterPlayerControlsConfiguration.subtitlesIcon,
                  translations.overflowMenuSubtitles, () {
                Navigator.of(context).pop();
                _showSubtitlesSelectionWidget();
              }, false),
            if (betterPlayerControlsConfiguration.enableQualities)
              // ListTile(
              //   leading: Icon(
              //     betterPlayerControlsConfiguration.qualitiesIcon,
              //     color: betterPlayerControlsConfiguration.overflowMenuIconsColor,
              //   ),
              //   title: Text(
              //     translations.overflowMenuQuality,
              //     style: _getOverflowMenuElementTextStyle(false),
              //   ),
              //   focusColor: Colors.blue,
              //   onTap: () {
              //     Navigator.of(context).pop();
              //     _showQualitiesSelectionWidget();
              //   },
              // ),
              _buildMoreOptionsListRow(
                  betterPlayerControlsConfiguration.qualitiesIcon,
                  translations.overflowMenuQuality, () {
                Navigator.of(context).pop();
                _showQualitiesSelectionWidget();
              }, false),
            if (betterPlayerControlsConfiguration.enableAudioTracks)
              // ListTile(
              //   leading: Icon(
              //     betterPlayerControlsConfiguration.audioTracksIcon,
              //     color: betterPlayerControlsConfiguration.overflowMenuIconsColor,
              //   ),
              //   title: Text(
              //     translations.overflowMenuAudioTracks,
              //     style: _getOverflowMenuElementTextStyle(false),
              //   ),
              //   focusColor: Colors.blue,
              //   onTap: () {
              //     Navigator.of(context).pop();
              //     _showAudioTracksSelectionWidget();
              //   },
              // ),
              _buildMoreOptionsListRow(
                  betterPlayerControlsConfiguration.audioTracksIcon,
                  translations.overflowMenuAudioTracks, () {
                Navigator.of(context).pop();
                _showAudioTracksSelectionWidget();
              }, false),
            if (betterPlayerControlsConfiguration
                .overflowMenuCustomItems.isNotEmpty)
              ...betterPlayerControlsConfiguration.overflowMenuCustomItems.map(
                (customItem) => _buildMoreOptionsListRow(
                  customItem.icon,
                  customItem.title,
                  () {
                    Navigator.of(context).pop();
                    customItem.onClicked.call();
                  }, false
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOptionsListRow(
      IconData icon, String name, void Function() onTap, bool autofocus) {
    return BetterPlayerMaterialClickableFocusWidget(
        iconVisible: true,
        icon: icon,
        name: name,
        onTap: onTap,
        autofocus: autofocus,
        color: betterPlayerControlsConfiguration.overflowMenuIconsColor,
        style: _getOverflowMenuElementTextStyle);
  }

  void _showSpeedChooserWidget() {
    _showModalBottomSheet([
      _buildSpeedRow(0.25, true),
      _buildSpeedRow(0.5, false),
      _buildSpeedRow(0.75, false),
      _buildSpeedRow(1.0, false),
      _buildSpeedRow(1.25, false),
      _buildSpeedRow(1.5, false),
      _buildSpeedRow(1.75, false),
      _buildSpeedRow(2.0, false),
    ]);
  }

  Widget _buildSpeedRow(double value, bool autofocus) {
    final bool isSelected =
        betterPlayerController!.videoPlayerController!.value.speed == value;

    return BetterPlayerMaterialClickableFocusWidget(
        iconVisible: isSelected,
        icon: Icons.check_outlined,
        name: "$value x",
        onTap: () {
          Navigator.of(context).pop();
          betterPlayerController!.setSpeed(value);
        },
        autofocus: autofocus,
        color:  betterPlayerControlsConfiguration.overflowModalTextColor,
        style: _getOverflowMenuElementTextStyle
    );
  }

  ///Latest value can be null
  bool isLoading(VideoPlayerValue? latestValue) {
    if (latestValue != null) {
      if (!latestValue.isPlaying && latestValue.duration == null) {
        return true;
      }

      final Duration position = latestValue.position;

      Duration? bufferedEndPosition;
      if (latestValue.buffered.isNotEmpty == true) {
        bufferedEndPosition = latestValue.buffered.last.end;
      }

      if (bufferedEndPosition != null) {
        final difference = bufferedEndPosition - position;

        if (latestValue.isPlaying &&
            latestValue.isBuffering &&
            difference.inMilliseconds < _bufferingInterval) {
          return true;
        }
      }
    }
    return false;
  }

  void _showSubtitlesSelectionWidget() {
    final subtitles =
        List.of(betterPlayerController!.betterPlayerSubtitlesSourceList);
    final noneSubtitlesElementExists = subtitles.firstWhereOrNull(
            (source) => source.type == BetterPlayerSubtitlesSourceType.none) !=
        null;
    if (!noneSubtitlesElementExists) {
      subtitles.add(BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.none));
    }

    _showModalBottomSheet(
        subtitles.asMap().entries.map((source) => _buildSubtitlesSourceRow(source.value, source.key == 0)).toList());
  }

  Widget _buildSubtitlesSourceRow(BetterPlayerSubtitlesSource subtitlesSource, bool autofocus) {
    final selectedSourceType =
        betterPlayerController!.betterPlayerSubtitlesSource;
    final bool isSelected = (subtitlesSource == selectedSourceType) ||
        (subtitlesSource.type == BetterPlayerSubtitlesSourceType.none &&
            subtitlesSource.type == selectedSourceType!.type);

    return BetterPlayerMaterialClickableFocusWidget(
        iconVisible: isSelected,
        icon: Icons.check_outlined,
        name: subtitlesSource.type == BetterPlayerSubtitlesSourceType.none
            ? betterPlayerController!.translations.generalNone
            : subtitlesSource.name ??
            betterPlayerController!.translations.generalDefault,
        onTap: () {
          Navigator.of(context).pop();
          betterPlayerController!.setupSubtitleSource(subtitlesSource);
        },
        autofocus: autofocus,
        color:  betterPlayerControlsConfiguration.overflowModalTextColor,
        style: _getOverflowMenuElementTextStyle
    );

      BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        betterPlayerController!.setupSubtitleSource(subtitlesSource);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: isSelected ? 8 : 16),
            Visibility(
                visible: isSelected,
                child: Icon(
                  Icons.check_outlined,
                  color:
                      betterPlayerControlsConfiguration.overflowModalTextColor,
                )),
            const SizedBox(width: 16),
            Text(
              subtitlesSource.type == BetterPlayerSubtitlesSourceType.none
                  ? betterPlayerController!.translations.generalNone
                  : subtitlesSource.name ??
                      betterPlayerController!.translations.generalDefault,
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
          ],
        ),
      ),
    );
  }

  ///Build both track and resolution selection
  ///Track selection is used for HLS / DASH videos
  ///Resolution selection is used for normal videos
  void _showQualitiesSelectionWidget() {
    // HLS / DASH
    final List<String> asmsTrackNames =
        betterPlayerController!.betterPlayerDataSource!.asmsTrackNames ?? [];
    final List<BetterPlayerAsmsTrack> asmsTracks =
        betterPlayerController!.betterPlayerAsmsTracks;
    final List<Widget> children = [];
    for (var index = 0; index < asmsTracks.length; index++) {
      final track = asmsTracks[index];

      String? preferredName;
      if (track.height == 0 && track.width == 0 && track.bitrate == 0) {
        preferredName = betterPlayerController!.translations.qualityAuto;
      } else {
        preferredName =
            asmsTrackNames.length > index ? asmsTrackNames[index] : null;
      }
      children.add(_buildTrackRow(asmsTracks[index], preferredName, index == 0));
    }

    // normal videos
    final resolutions =
        betterPlayerController!.betterPlayerDataSource!.resolutions;
    resolutions?.forEach((key, value) {
      children.add(_buildResolutionSelectionRow(key, value));
    });

    if (children.isEmpty) {
      children.add(
        _buildTrackRow(BetterPlayerAsmsTrack.defaultTrack(),
            betterPlayerController!.translations.qualityAuto, true),
      );
    }

    _showModalBottomSheet(children);
  }

  Widget _buildTrackRow(BetterPlayerAsmsTrack track, String? preferredName, bool autofocus) {
    final int width = track.width ?? 0;
    final int height = track.height ?? 0;
    final int bitrate = track.bitrate ?? 0;
    final String mimeType = (track.mimeType ?? '').replaceAll('video/', '');
    final String trackName = preferredName ??
        "${width}x$height ${BetterPlayerUtils.formatBitrate(bitrate)} $mimeType";

    final BetterPlayerAsmsTrack? selectedTrack =
        betterPlayerController!.betterPlayerAsmsTrack;
    final bool isSelected = selectedTrack != null && selectedTrack == track;

    return BetterPlayerMaterialClickableFocusWidget(
        iconVisible: isSelected,
        icon: Icons.check_outlined,
        name: trackName,
        onTap: () {
          Navigator.of(context).pop();
          betterPlayerController!.setTrack(track);
        },
        autofocus: autofocus,
        color:  betterPlayerControlsConfiguration.overflowModalTextColor,
        style: _getOverflowMenuElementTextStyle
    );

    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        betterPlayerController!.setTrack(track);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: isSelected ? 8 : 16),
            Visibility(
                visible: isSelected,
                child: Icon(
                  Icons.check_outlined,
                  color:
                      betterPlayerControlsConfiguration.overflowModalTextColor,
                )),
            const SizedBox(width: 16),
            Text(
              trackName,
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionSelectionRow(String name, String url) {
    final bool isSelected =
        url == betterPlayerController!.betterPlayerDataSource!.url;
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        betterPlayerController!.setResolution(url);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: isSelected ? 8 : 16),
            Visibility(
                visible: isSelected,
                child: Icon(
                  Icons.check_outlined,
                  color:
                      betterPlayerControlsConfiguration.overflowModalTextColor,
                )),
            const SizedBox(width: 16),
            Text(
              name,
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioTracksSelectionWidget() {
    //HLS / DASH
    final List<BetterPlayerAsmsAudioTrack>? asmsTracks =
        betterPlayerController!.betterPlayerAsmsAudioTracks;
    final List<Widget> children = [];
    final BetterPlayerAsmsAudioTrack? selectedAsmsAudioTrack =
        betterPlayerController!.betterPlayerAsmsAudioTrack;
    if (asmsTracks != null) {
      for (var index = 0; index < asmsTracks.length; index++) {
        final bool isSelected = selectedAsmsAudioTrack != null &&
            selectedAsmsAudioTrack == asmsTracks[index];
        children.add(_buildAudioTrackRow(asmsTracks[index], isSelected, index == 0));
      }
    }

    if (children.isEmpty) {
      children.add(
        _buildAudioTrackRow(
          BetterPlayerAsmsAudioTrack(
            label: betterPlayerController!.translations.generalDefault
          ),
          true, true
        ),
      );
    }

    _showModalBottomSheet(children);
  }

  Widget _buildAudioTrackRow(
      BetterPlayerAsmsAudioTrack audioTrack, bool isSelected, bool autofocus) {
    return BetterPlayerMaterialClickableFocusWidget(
        iconVisible: isSelected,
        icon: Icons.check_outlined,
        name: audioTrack.label!,
        onTap: () {
          Navigator.of(context).pop();
          betterPlayerController!.setAudioTrack(audioTrack);
        },
        autofocus: autofocus,
        color:  betterPlayerControlsConfiguration.overflowModalTextColor,
        style: _getOverflowMenuElementTextStyle
    );

    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        Navigator.of(context).pop();
        betterPlayerController!.setAudioTrack(audioTrack);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: isSelected ? 8 : 16),
            Visibility(
                visible: isSelected,
                child: Icon(
                  Icons.check_outlined,
                  color:
                      betterPlayerControlsConfiguration.overflowModalTextColor,
                )),
            const SizedBox(width: 16),
            Text(
              audioTrack.label!,
              style: _getOverflowMenuElementTextStyle(isSelected),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getOverflowMenuElementTextStyle(bool isSelected) {
    return TextStyle(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      color: isSelected
          ? betterPlayerControlsConfiguration.overflowModalTextColor
          : betterPlayerControlsConfiguration.overflowModalTextColor
              .withOpacity(0.7),
    );
  }

  void _showModalBottomSheet(List<Widget> children) {
    Platform.isAndroid
        ? _showMaterialBottomSheet(children)
        : _showCupertinoModalBottomSheet(children);
  }

  void _showCupertinoModalBottomSheet(List<Widget> children) {
    showCupertinoModalPopup<void>(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: betterPlayerControlsConfiguration.overflowModalColor,
                /*shape: RoundedRectangleBorder(side: Bor,borderRadius: 24,)*/
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0)),
              ),
              child: Column(
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMaterialBottomSheet(List<Widget> children) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: betterPlayerControlsConfiguration.overflowModalColor,
                /*shape: RoundedRectangleBorder(side: Bor,borderRadius: 24,)*/
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0)),
              ),
              child: Column(
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }

  ///Builds directionality widget which wraps child widget and forces left to
  ///right directionality.
  Widget buildLTRDirectionality(Widget child) {
    return Directionality(textDirection: TextDirection.ltr, child: child);
  }
}
