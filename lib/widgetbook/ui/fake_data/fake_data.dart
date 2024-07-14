import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';

final fakeUsers = Users(
  id: 43,
  name: 'test',
  userName: 'testName',
  selfIntroduce: 'This is test account',
  image: 'assets/icon/icon3.png',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  userId: '1ee46691-2164-4832-86ac-8e5f847d1430',
  exchangedPoint: 0,
);

final fakePosts = Posts(
  id: 43,
  foodImage:
      '1ee46691-2164-4832-86ac-8e5f847d1430/image_picker_1E24011B-E41A-4776-B9B7-245E2DB9A386-7545-00000177D1BC3E52.jpg',
  foodName: 'test food',
  restaurant: 'test restaurant',
  comment: 'test comment',
  createdAt: DateTime.now(),
  lat: 35.6809591,
  lng: 139.7673068,
  userId: '1ee46691-2164-4832-86ac-8e5f847d1430',
  heart: 100,
);
