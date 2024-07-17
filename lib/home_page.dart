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
          title: Text('Delete Video'),
          content: Text('Are you sure you want to delete this video?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
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
              child: Text('Delete'),
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

  void _showEmptySearchAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Field Empty'),
          content: Text('Please enter a title to search for videos.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
                  icon: Icon(Icons.search, color: AppColors.black87),
                  controller: _searchController,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppBorders.radius),
                ),
                height: MediaQuery.of(context).size.height,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridTile(
                          header: GridTileBar(
                            leading: const Icon(Icons.play_arrow),
                            backgroundColor: Colors.black54,
                            title: Text(video['title']),
                          ),
                          footer: GridTileBar(
                            backgroundColor: Colors.black54,
                            leading: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () {
                                    _shareVideo(video['videoFile']);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteVideo(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                          child: Image.file(
                            File(video['thumbnail']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: AppPaddings.horizontal24,
            child:
                Text(AppStrings.enterKeyword, style: AppTextStyles.modalTitle),
          ),
          Padding(
            padding: AppPaddings.horizontal24,
            child: CustomTextField(
              hintText: AppStrings.exampleHint,
              icon: null,
              controller: _titleController,
            ),
          ),
          Padding(
            padding: AppPaddings.horizontal24,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.red),
                color: AppColors.lightRed,
                borderRadius: BorderRadius.circular(AppBorders.radius),
              ),
              child: InkWell(
                onTap: _pickVideo,
                child: _videoFile == null
                    ? const Padding(
                        padding: AppPaddings.horizontal24,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Center(
                                  child: Image(
                                    height: 70,
                                    image: AssetImage('assets/images/bg.png'),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 8.5),
                                    child: Image(
                                      height: 40,
                                      image:
                                          AssetImage('assets/images/video.png'),
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
                    : const Center(child: Text("Video Added")),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty && _videoFile != null) {
                  widget.onAddVideo(_titleController.text, _videoFile!);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width * 0.9, 49),
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
        ],
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
        title: const Text('Video Player'),
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
