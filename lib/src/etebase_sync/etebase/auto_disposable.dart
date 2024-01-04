typedef DisposeCallback<T> = Future<void> Function(T instance);

sealed class AutoDisposable<T> {
  factory AutoDisposable(T instance, DisposeCallback<T> onDispose) =
      _ItemDisposable;

  const AutoDisposable._();

  T get instance;

  Future<void> dispose();

  static List<AutoDisposable<TItem>> list<TList, TItem>(
    TList list,
    DisposeCallback<TList> onDispose,
    List<TItem> items,
  ) {
    final ref = _ListRef(list, onDispose, items.length);
    return items.map((item) => _ListDisposable(item, ref)).toList();
  }
}

class _ItemDisposable<T> extends AutoDisposable<T> {
  @override
  final T instance;
  final DisposeCallback<T> onDispose;

  const _ItemDisposable(this.instance, this.onDispose) : super._();

  @override
  Future<void> dispose() => onDispose(instance);
}

class _ListDisposable<T> extends AutoDisposable<T> {
  @override
  final T instance;
  final _ListRef listRef;

  const _ListDisposable(this.instance, this.listRef) : super._();

  @override
  Future<void> dispose() => listRef.deref();
}

class _ListRef<TList, TItem> {
  final TList list;
  final DisposeCallback<TList> onDispose;

  int refCount;

  _ListRef(this.list, this.onDispose, this.refCount);

  Future<void> deref() async {
    if (--refCount == 0) {
      await onDispose(list);
    }
  }
}
