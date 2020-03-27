// Copyright 2019 Gohilla Ltd (https://gohilla.com).
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/utils.dart';

/// A result of [HashAlgorithm].
class Hash {
  final List<int> bytes;

  Hash(this.bytes) {
    ArgumentError.checkNotNull(bytes, 'bytes');
  }

  @override
  int get hashCode => constantTimeBytesEquality.hash(bytes);

  @override
  bool operator ==(other) =>
      other is Hash && constantTimeBytesEquality.equals(bytes, other.bytes);

  @override
  String toString() => 'Hash(...)';
}

/// Superclass for hash algorithms.
///
/// Examples:
///   * [blake2s]
///   * [sha1]
///   * [sha224] (SHA2-224)
///   * [sha256] (SHA2-256)
///   * [sha384] (SHA2-384)
///   * [sha512] (SHA2-512)
///   * [sha3V224] (SHA3-224)
///   * [sha3V256] (SHA3-256)
///   * [sha3V384] (SHA3-384)
///   * [sha3V521] (SHA3-521)
///
abstract class HashAlgorithm {
  String get name;

  /// Hash length in bytes.
  int get hashLengthInBytes;

  /// Block length in bytes.
  int get blockLength;

  const HashAlgorithm();

  /// Calculates hash for the input.
  Future<Hash> hash(List<int> input) {
    return Future<Hash>(() => hashSync(input));
  }

  /// Synchronous version of [hash].
  Hash hashSync(List<int> input) {
    ArgumentError.checkNotNull(input);
    final sink = newSink();
    sink.add(input);
    return sink.closeSync();
  }

  /// Constructs a new sink for synchronous hashing.
  HashSink newSink();
}

/// A sink created by [HashAlgorithm].
abstract class HashSink implements ByteConversionSink {
  @override
  void add(List<int> chunk) {
    addSlice(chunk, 0, chunk.length, false);
  }

  /// Closes the sink and calculates hash for all added bytes.
  @override
  Future<Hash> close() {
    return Future<Hash>(() => closeSync());
  }

  /// Synchronous version of [close].
  Hash closeSync();
}
