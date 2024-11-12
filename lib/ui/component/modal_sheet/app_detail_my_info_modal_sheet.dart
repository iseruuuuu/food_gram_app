                          onTap: () async {
                            context
                              ..pop()
                              ..pop(true);
                            await ref
                                .read(detailPostViewModelProvider().notifier)
                                .delete(posts);
                          },
                        );
