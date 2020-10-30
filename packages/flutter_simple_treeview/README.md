# flutter_simple_treeview
This widget visualises a tree structure, where a node can be any widget.

## Demo

[https://flutter_simple_treeview.surge.sh/](https://flutter_simple_treeview.surge.sh/)

## Usage

```
                  TreeView(nodes: [
                    TreeNode(content: Text("root1")),
                    TreeNode(
                      content: Text("root2"),
                      children: [
                        TreeNode(content: Text("child21")),
                        TreeNode(content: Text("child22")),
                        TreeNode(
                          content: Text("root23"),
                          children: [
                            TreeNode(content: Text("child231")),
                          ],
                        ),
                      ],
                    ),
                  ]),
```
