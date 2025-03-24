// import 'package:get/get.dart';
// import 'package:text_to_image/models/collection_model.dart';
// import 'package:text_to_image/service/database_helper.dart';

// class CollectionController extends GetxController{
//   var collections = <CollectionModel>[].obs;
//   var isLoading = false.obs;
//   var selectedCollectionId = 1.obs; 


//   @override
//   void onInit() {
//     loadCollections();
//     super.onInit();
//   }


//     Future<void> loadCollections() async {
//     isLoading.value = true;
//     try {
//       collections.value = await DatabaseHelper.getCollections();
//     } catch (e) {
//       print('Error loading collections: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<bool> createCollection(String name, {String? description}) async {
//     try {
//       final id = await DatabaseHelper.createCollection(name, description: description);
//       if (id > 0) {
//         await loadCollections();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print('Error creating collection: $e');
//       return false;
//     }
//   }

//   Future<bool> updateCollection(CollectionModel collection) async {
//     try {
//       final result = await DatabaseHelper.updateCollection(collection);
//       if (result > 0) {
//         await loadCollections();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print('Error updating collection: $e');
//       return false;
//     }
//   }

//   Future<bool> deleteCollection(int id) async {
//     // Don't allow deleting the default collection
//     if (id == 1) return false;

//     try {
//       final result = await DatabaseHelper.deleteCollection(id);
//       if (result > 0) {
//         // If we're deleting the currently selected collection, go back to "All Images"
//         if (selectedCollectionId.value == id) {
//           selectedCollectionId.value = 1;
//         }
//         await loadCollections();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print('Error deleting collection: $e');
//       return false;
//     }
//   }

//   void setSelectedCollection(int id) {
//     selectedCollectionId.value = id;
//   }
// }