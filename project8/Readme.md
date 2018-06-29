## Project 9 - File System

Dos Fat, consider what interfaces are needed to be compatible with VFS.

Linux Ext file system.

Ext2:

+ 文件系统结构：引导扇区+块组
+ 块组：超级块+组描述符+数据块位图+索引节点位图+索引节点表+数据块
    * 超级块(每个块组一个备份)
        - int s_inodes_count
        - int s_blocks_count
        - int s_r_blocks_count
        - int s_free_blocks_count
        - int s_free_inodes_count
        - int s_first_data_block
        - int s_log_block_size
        - int s_first_ino
    * 组描述符(每个块组一个备份)
        - int bg_block_bitmap
        - int bg_inode_bitmap
        - int bg_inode_table
        - int bg_free_blocks_count
        - int bg_free_inodes_count
        - int bg_used_dirs_count
    * 索引节点表
        - int i_mode
        - int i_uid
        - int i_size
        - int i_blocks
        - int i_flags
        - int i_block\[EXT2_N_BLOCKS\](选择为15)
            （注意数据块多级寻址）
        - 文件类型
        

          |文件类型|说明|
          |:---- |:---- |
          |0|未知|
          |1|普通文件|
          |2|目录|

          目录格式

          + int inode
          + short rec_len
          + short name_len
          + short file_type
          + char name[EXT2_NAME_LEN]

    * 目录高速缓存
        + hash
        + from path to inode number
    * Related to process mechanism:
        + file_struct（进程打开的文件）
            * int count
            * semaphore file_lock
            * struct inode * open_file
        + fs_struct（进程的文件系统）
            * int count
            * semaphore lock
            * struct dentry* root
            * struct dentry* pwd

系统调用：

+ open
+ read
+ write
+ seek
+ close

Simulate the virtual file system struct in Linux(Unix).

+ Pay attention to the use of lock in file system.
+ Hash to improve effciency(in catalog cache).

- SuperBlock.
    包含一个指向EXT2的超级块的指针，以及一个操作结构。  
- Index Node.
    包含一个指向EXT2的索引的指针，以及一个操作结构。 
- Catalog(struct dentry)
    + struct inode * d_inode
    + struct dentry * d_parent
    + char name[EXT2_NAME_LEN]
    + 操作结构
- File.
    包含一个指向EXT2的file_struct的指针，以及一个操作结构。 
    


Other auxiliary mechanism:
+ write buffer.
    块队列、脏位、int i_block

Refer to the source code of Linux.


垃圾实现：
在进程表里操作，一个进程打开一个文件，记录File指针，该结构体包含文件对象和文件操作对象，file_struct里面有名字，引用计数，文件锁，内容偏移量。

文件不应当传回内容指针，读写操作应当与缓存区打交道。

创建与删除


### Traps 
pop ds
解决了ds问题
函数指针用法
loadReal是错的，我以前是怎么做对的。