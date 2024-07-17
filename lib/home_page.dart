import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_repo/components/custom_text_field.dart';
import 'package:video_repo/localization/strings.dart';
import 'package:video_repo/styles/styles.dart';
import 'package:video_repo/utils/constants.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _videos = [];
  List<Map<String, dynamic>> _filteredVideos = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _searchController.addListener(_filterVideos);
  }

  Future<void> _loadVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final videosString = prefs.getString('videos');
    if (videosString != null) {
      setState(() {
        _videos = List<Map<String, dynamic>>.from(json.decode(videosString));
        _filteredVideos = _videos;
      });
    }
  }

  Future<void> _saveVideos() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('videos', json.encode(_videos));
  }

  void _addVideo(String title, XFile videoFile) async {
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      imageFormat: ImageFormat.PNG,
      maxWidth: 128,
      quality: 25,
    );

    setState(() {
      _videos.add({
        'title': title,
        'videoFile': videoFile.path,
        'thumbnail': thumbnail,
      });
      _filteredVideos = _videos;
      _saveVideos();
    });
  }

  void _deleteVideo(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Video'),
          content: const Text('Are you sure you want to delete this video?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _videos.removeAt(index);
                  _filteredVideos = _videos;
                  _saveVideos();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _shareVideo(String videoFilePath) {
    XFile videoFile = XFile(videoFilePath);
    Share.shareXFiles([videoFile], text: 'Check out this video!');
  }

  void _filterVideos() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredVideos = _videos;
      } else {
        _filteredVideos = _videos
            .where((video) => video['title']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            snap: true,
            centerTitle: true,
            floating: true,
            title: const Padding(
              padding: AppPaddings.all8,
              child: Text(AppStrings.appBarTitle,
                  style: AppTextStyles.appBarTitle),
            ),
            bottom: AppBar(
              title: Padding(
                padding: AppPaddings.all8,
                child: CustomTextField(
                  hintText: AppStrings.searchHint,
                  icon: null,
                  controller: _searchController,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _filteredVideos.length,
                itemBuilder: (context, index) {
                  final video = _filteredVideos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            videoFile: File(video['videoFile']),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppBorders.radius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                        image: DecorationImage(
                          image: FileImage(File(video['thumbnail'])),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(AppBorders.radius)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        video['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.share,
                                            color: Colors.white),
                                        onPressed: () {
                                          _shareVideo(video['videoFile']);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.white),
                                        onPressed: () {
                                          _deleteVideo(index);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 64,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return AddVideoModal(onAddVideo: _addVideo);
                },
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              fixedSize: Size(MediaQuery.of(context).size.width * 0.9, 55),
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorders.radius),
              ),
            ),
            child: const Text(AppStrings.addNewVideo,
                style: AppTextStyles.modalButtonText),
          ),
        ),
      ],
    );
  }
}

class AddVideoModal extends StatefulWidget {
  final Function(String, XFile) onAddVideo;

  const AddVideoModal({required this.onAddVideo, super.key});

  @override
  _AddVideoModalState createState() => _AddVideoModalState();
}

class _AddVideoModalState extends State<AddVideoModal> {
  final TextEditingController _titleController = TextEditingController();
  XFile? _videoFile;

  void _pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    setState(() {
      _videoFile = pickedFile;
    });
  }

  void _showEmptyTitleAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Empty Title'),
          content: const Text('Please enter a title for the video.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom), // Adjust padding to move above keyboard
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24), // Add top padding
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(AppStrings.enterKeyword,
                    style: AppTextStyles.modalTitle),
              ),
              const SizedBox(height: 16), // Add spacing between elements
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CustomTextField(
                  hintText: AppStrings.exampleHint,
                  icon: null,
                  controller: _titleController,
                ),
              ),
              const SizedBox(height: 16), // Add spacing between elements
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.red),
                    color: AppColors.lightRed,
                    borderRadius: BorderRadius.circular(AppBorders.radius),
                  ),
                  child: InkWell(
                    onTap: _pickVideo,
                    child: _videoFile == null
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Center(
                                      child: Image(
                                        height: 70,
                                        image:
                                            AssetImage('assets/images/bg.png'),
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 8.5),
                                        child: Image(
                                          height: 40,
                                          image: AssetImage(
                                              'assets/images/video.png'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(AppStrings.selectVideo,
                                    style: AppTextStyles.selectVideoText),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 50,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Video Added",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Add spacing between elements
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isEmpty) {
                      _showEmptyTitleAlert();
                    } else if (_videoFile != null) {
                      widget.onAddVideo(_titleController.text, _videoFile!);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                        Size(MediaQuery.of(context).size.width * 0.9, 49),
                    backgroundColor:
                        _videoFile == null ? AppColors.red : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorders.radius),
                    ),
                  ),
                  child: const Text(AppStrings.add,
                      style: AppTextStyles.modalButtonText),
                ),
              ),
              const SizedBox(height: 24), // Add bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;

  const VideoPlayerScreen({required this.videoFile, super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share,
              color: AppColors.black87,
              size: 26,
            ),
            onPressed: () {
              Share.shareXFiles([XFile(widget.videoFile.path)],
                  text: 'Check out this video!');
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: AppColors.black87,
            size: 26,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'VIDEO PLAYER',
          style: AppTextStyles.appBarTitle,
        ),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
