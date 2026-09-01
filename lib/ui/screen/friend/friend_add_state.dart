class FriendAddState {
  const FriendAddState({
    this.myFriendCode = '',
    this.isLoadingCode = true,
  });

  final String myFriendCode;
  final bool isLoadingCode;

  FriendAddState copyWith({
    String? myFriendCode,
    bool? isLoadingCode,
  }) {
    return FriendAddState(
      myFriendCode: myFriendCode ?? this.myFriendCode,
      isLoadingCode: isLoadingCode ?? this.isLoadingCode,
    );
  }
}
