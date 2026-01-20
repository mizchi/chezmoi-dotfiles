---
title: "Segment Trees (Part 2) — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/example/segment-tree/segment-tree2"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/example/segment-tree/segment-tree2.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/example/segment-tree/segment-tree2.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Fexample/segment-tree/segment-tree2.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/example/segment-tree/segment-tree2.md "Download source file")
* .pdf

# Segment Trees (Part 2)

## Contents

# Segment Trees (Part 2)[#](https://docs.moonbitlang.com/en/stable/example/segment-tree/segment-tree2.html#segment-trees-part-2 "Link to this heading")

## Introduction[#](https://docs.moonbitlang.com/en/stable/example/segment-tree/segment-tree2.html#introduction "Link to this heading")

In the previous article, we discussed the basic implementation of a segment tree. That tree only allowed range queries (single-point modifications and queries were also possible), but it couldn't handle range modifications, such as adding a value to all elements in a given range.

In this session, we will deepen the abstraction by introducing the concept of **LazyTag** to handle range modifications, creating a more functional segment tree.

## How to Implement Range Modifications?[#](https://docs.moonbitlang.com/en/stable/example/segment-tree/segment-tree2.html#how-to-implement-range-modifications "Link to this heading")

First, let's imagine what happens if we add a number to all elements in a range on the segment tree. How would we do this using a straightforward approach?

![add to segment tree](https://docs.moonbitlang.com/en/stable/_images/segment-tree-add.png)

Take the segment tree from the last lesson as an example. In the figure below, we add 1 to the range [4, 7]. You'll notice that we need to rebuild and maintain all parts of the tree that cover this range, which is too costly.

Is there a better way? Of course! We can use **LazyTag**.

![lazytag](https://docs.moonbitlang.com/en/stable/_images/segment-tree-lazytag.png)

Consider that instead of modifying every affected part, we mark the smallest covering range with a "+1" tag. Based on the length of the range, we calculate its value and merge it upward. Following the complexity of querying from the last lesson, this operation would be O(log N).

However, there's a problem. While querying ranges like [1, 7] or [4, 7] works fine, what if we query [4, 6]? The minimal covering ranges are [4, 5] and [6, 6], not [4, 7], so our tag doesn't propagate to lower nodes.

Here’s where the **Lazy** aspect of LazyTag comes into play.

![add using lazytag](https://docs.moonbitlang.com/en/stable/_images/segment-tree-add-lazytag.png)

We define that when querying a node with a tag, the tag is distributed to its child nodes. These child nodes inherit the tag and compute their values based on their length. The following diagram shows the propagation of the tag downward when querying [4, 6].

This "lazy propagation" ensures that each modification is completed in O(log N), while ensuring correct query results.

Note

Some may wonder about overlapping tags. However, additive tags like these merge seamlessly without affecting the total sum of a node.

Let’s dive into the code!

## Implementation[#](https://docs.moonbitlang.com/en/stable/example/segment-tree/segment-tree2.html#implementation "Link to this heading")

### Basic Definition[#](https://docs.moonbitlang.com/en/stable/example/segment-tree/segment-tree2.html#basic-definition "Link to this heading")

In the previous code, we defined the segment tree using `enum`. However, none of the elements were clearly named, which was manageable when the data size was small. Now, we need to add **Tag** and **Length** attributes, so it makes sense to use labeled arguments in the `enum` definition:

```
///|
enum Data {
  Data(sum~ : Int, len~ : Int)
}

///|
enum LazyTag {
  Nil
  Tag(Int)
}

///|
enum Node {
  Nil
  Node(data~ : Data, tag~ : LazyTag, left~ : Node, right~ : Node)
}
```

This allows for clearer initialization and pattern matching, making the code easier to follow. We've also abstracted the `Data` type, adding a `len` attribute to represent the length of the current range, which is useful for calculating the node's value.

### Building the Tree[#](https://docs.moonbitlang.com/en/stable/example/segment-tree/segment-tree2.html#building-the-tree "Link to this heading")

Similar to the last lesson, before building the tree, we need to define the addition operations between `Node` types. However, since we’ve abstracted `Data`, we must account for its addition too:

```
///|
impl Add for Data with add(self : Data, v : Data) -> Data {
  match (self, v) {
    (Data(sum=a, len=len_a), Data(sum=b, len=len_b)) =>
      Data(sum=a + b, len=len_a + len_b)
  }
}

///|
impl Add for Node with add(self : Node, v : Node) -> Node {
  match (self, v) {
    (Node(data=l, ..), Node(data=r, ..)) =>
      Node(data=l + r, tag=Nil, left=self, right=v)
    (Node(_), Nil) => self
    (Nil, Node(_)) => v
    (Nil, Nil) => Nil
  }
}
```

Here, we’ve ignored merging LazyTags for now and set the resulting tag to `Nil` because once a node is reached, its parent’s LazyTag no longer applies.

Now, we can implement the tree-building function:

```
///|
fn build(data : ArrayView[Int]) -> Node {
  if data.length() == 1 {
    Node(data=Data(sum=data[0], len=1), tag=Nil, left=Nil, right=Nil)
  } else {
    let mid = (data.length() + 1) >> 1
    build(data[0:mid]) + build(data[mid:])
  }
}
```

### LazyTag and Range Modifications[#](https://docs.moonbitlang.com/en/stable/example/segment-tree/segment-tree2.html#lazytag-and-range-modifications "Link to this heading")

We define a node receiving a LazyTag as `apply`. The key logic lies in here: the node receiving the LazyTag may not own a LazyTag, and if it did own one, how do we merge them? And how do we compute the new value of the node based on the LazyTag?

A decent implementation is to define a new addition operation to merge LazyTags, and define an `apply` function for Node to receive it.

```
///|
impl Add for LazyTag with add(self : LazyTag, v : LazyTag) -> LazyTag {
  match (self, v) {
    (Tag(a), Tag(b)) => Tag(a + b)
    (Nil, t) | (t, Nil) => t
  }
}

///|
fn apply(self : Node, v : LazyTag) -> Node {
  match (self, v) {
    (Node(data=Data(sum=a, len=length), tag~, left~, right~), Tag(v) as new_tag) =>
      Node(
        data=Data(sum=a + v * length, len=length),
        tag=tag + new_tag,
        left~,
        right~,
      )
    (_, Nil) => self
    (Nil, _) => Nil
  }
}
```

Here is the core part of this section: compute the correct node's value with the segment's length and the value of LazyTag.

Then how do we implement range modifications?

```
///|
fn modify(
  self : Node,
  l : Int,
  r : Int,
  modify_l : Int,
  modify_r : Int,
  tag : LazyTag
) -> Node {
  if modify_l > r || l > modify_r {
    self
  } else if modify_l <= l && modify_r >= r {
    self.apply(tag)
  } else {
    guard self is Node(left~, right~, ..)
    let mid = (l + r) >> 1
    left.modify(l, mid, modify_l, modify_r, tag) +
    right.modify(mid + 1, r, modify_l, modify_r, tag)
  }
}
```

The logic is similar to the query function from the previous lesson, but now each relevant node applies the necessary LazyTag for the modification.

When we arrive here, we find that, even with the range modification, it's still a persistent, or **Immutable** segment tree. The `modify` function will return the recently created segment tree, without changing the original one, and the semantics of recurring and merging represent this vividly.

This means that using these kind of implementations (ADT(enum), recursion) for meeting immutable requirements is natural and elegant. With the garbage collection mechanism of MoonBit, we don't need to use pointers **explicitly** for some relationships in recurring ADT(enum), and we don't need to take care of the memory.

Readers unfamiliar with the functional programming languages may not notice this, but we actually always profit from it. For example, writing a `ConsList` in Rust using ADT(enum), we usually need:

```
enum List<T> {
    Cons(T, Box<List<T>>),
    Nil,
}
```

But in MoonBit, we only need:

```
enum List[T] {
  Cons(T, List[T])
  Nil
}
```

GC is really interesting!

### Queries[#](https://docs.moonbitlang.com/en/stable/example/segment-tree/segment-tree2.html#queries "Link to this heading")

For queries, we need to remember to push the LazyTag downwards:

```
///|
let empty_node : Node = Node(
  data=Data(sum=0, len=0),
  tag=Nil,
  left=Nil,
  right=Nil,
)

///|
fn query(self : Node, l : Int, r : Int, query_l : Int, query_r : Int) -> Node {
  if query_l > r || l > query_r {
    empty_node
  } else if query_l <= l && query_r >= r {
    self
  } else {
    guard self is Node(tag~, left~, right~, ..)
    let mid = (l + r) >> 1
    left.apply(tag).query(l, mid, query_l, query_r) +
    right.apply(tag).query(mid + 1, r, query_l, query_r)
  }
}
```

## Conclusion[#](https://docs.moonbitlang.com/en/stable/example/segment-tree/segment-tree2.html#conclusion "Link to this heading")

With this, we have a segment tree that supports range modifications and is much more functional!

In the next lesson, we’ll add multiplication support to the segment tree and explore some use cases for immutable segment trees. Stay tuned!

Full code is available [here](https://docs.moonbitlang.com/en/stable/_downloads/d087ac87400271bbac0155b3d6da7d2c/top.mbt).

Contents
