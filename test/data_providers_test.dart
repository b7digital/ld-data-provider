import 'package:data_providers/crud_data_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class Post{
  final int id,userId;
  final String title;

  Post({this.id, this.userId, this.title});

  factory Post.fromJson(json){
    return Post(id: json["id"],userId: json["userId"],title: json["title"]);
  }
}
void main() {
  CrudNetworkProvider.baseUrl = "http://jsonplaceholder.typicode.com/";
  final postProvider = CrudNetworkProvider<Post>("posts",filter: {},fromJson: (e) => Post.fromJson(e));

  //this test is piece of "shiet"
  test('Load and parse data is valid', () async {
    await postProvider.next();
    final first = postProvider.data[0];
    expect(first.title,"sunt aut facere repellat provident occaecati excepturi optio reprehenderit");
    expect(first.id, 1);
    expect(first.userId, 1);
  });
}
