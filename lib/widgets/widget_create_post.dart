import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import '../theme/glass_theme.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/database_service.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class CreatePostBottomSheet extends StatefulWidget {
  const CreatePostBottomSheet({super.key});

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final TextEditingController _descriptionController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  File? _selectedImage;
  bool _isLoading = false;

  List<AssetEntity> _mediaList = [];
  AssetPathEntity? _recentAlbum;
  bool _isGalleryLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 100;

  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
    imageOption: const FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
    ),
    orders: [
      const OrderOption(type: OrderOptionType.createDate, asc: false),
    ],
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchInitialGalleryMedia();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore && _hasMore) {
        _fetchMoreMedia();
      }
    }
  }

  Future<void> _fetchInitialGalleryMedia() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();

      if (ps.isAuth || ps.hasAccess) {
        List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
          type: RequestType.image,
          onlyAll: true,
          filterOption: _filterOptionGroup,
        );

        if (albums.isNotEmpty) {
          _recentAlbum = albums[0];
          _currentPage = 0;

          List<AssetEntity> media = await _recentAlbum!.getAssetListRange(
            start: 0,
            end: _pageSize,
          );

          if (mounted) {
            setState(() {
              _mediaList = media;
              _isGalleryLoading = false;
              _hasMore = media.length >= _pageSize;
            });
          }
        } else {
          if (mounted) setState(() => _isGalleryLoading = false);
        }
      } else {
        if (mounted) setState(() => _isGalleryLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isGalleryLoading = false);
    }
  }

  Future<void> _fetchMoreMedia() async {
    if (_isFetchingMore || !_hasMore || _recentAlbum == null) return;

    setState(() {
      _isFetchingMore = true;
    });

    try {
      final int start = (_currentPage + 1) * _pageSize;
      final int end = start + _pageSize;

      final List<AssetEntity> newMedia = await _recentAlbum!.getAssetListRange(
        start: start,
        end: end,
      );

      if (mounted) {
        setState(() {
          if (newMedia.isNotEmpty) {
            _mediaList.addAll(newMedia);
            _currentPage++;
          }
          _hasMore = newMedia.length >= _pageSize;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingMore = false);
      }
    }
  }

  Future<void> _submitPost() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter post description')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _databaseService.uploadImageToCloudinary(_selectedImage!);
        if (imageUrl == null) throw Exception("Не вдалося завантажити фотографію");
      }

      await _databaseService.createPost(
        description: _descriptionController.text.trim(),
        postImageUrl: imageUrl,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: GlassContainer(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
          shape: const LiquidVerticalRoundedSuperellipse(
            topRadius: 25,
            bottomRadius: 0,
          ),
          settings: ShowcaseGlassTheme.profilePanelDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 80, height: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Create New Post',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              AdaptiveLiquidGlassLayer(
                  settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                  child: GlassTextArea(
                    controller: _descriptionController,
                    maxLines: 3,
                    placeholder: 'Tell about yourself...',
                    shape: const LiquidRoundedSuperellipse(borderRadius: 15),
                    placeholderStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                  )
              ),

              const SizedBox(height: 15),
              Expanded(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      color: Colors.white12,
                      child: _selectedImage != null
                          ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: GlassButton(
                              icon: const Icon(
                                Icons.close,
                                size: 30,
                                color: Colors.white,
                              ),
                              width: 40,
                              height: 40,
                              settings: ShowcaseGlassTheme.profileButtonTopBar,
                              onTap: () {
                                setState(() => _selectedImage = null);
                              },
                            ),
                          ),
                        ],
                      )
                          : _isGalleryLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : _mediaList.isEmpty
                          ? const Center(child: Text("No photos found", style: TextStyle(color: Colors.white54)))
                          : GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: _mediaList.length + (_hasMore ? 3 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _mediaList.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
                              ),
                            );
                          }

                          return FutureBuilder<Uint8List?>(
                            future: _mediaList[index].thumbnailDataWithSize(const ThumbnailSize(200, 200)),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                                return GestureDetector(
                                  onTap: () async {
                                    File? file = await _mediaList[index].file;
                                    setState(() => _selectedImage = file);
                                  },
                                  child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                                );
                              }
                              return Container(color: Colors.white12);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : ElevatedButton(
                  onPressed: _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Share Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}