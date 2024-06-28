type Listener<T> = (value: T) => void;

export class EventEmitter<T> {
  private listeners: Set<Listener<T>> = new Set();

  addListener(listener: Listener<T>) {
    this.listeners.add(listener);
  }

  removeListener(listener: Listener<T>) {
    return this.listeners.delete(listener);
  }

  emit(value: T) {
    for (const listener of this.listeners) {
      listener(value);
    }
  }
}
