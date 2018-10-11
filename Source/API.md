

## API Instructions

以下是 API 使用用例及说明。

[User / 用户](API.md/#用户)

- [x] [register](API.md/#注册)
- [x] [login](API.md/#登录)
- [x] [change password](API.md/#修改密码)
- [x] [get user info ](API.md/#获取用户信息)
- [x] [modify user info ](API.md/#修改用户信息)
- [x] [logout ](API.md/#退出登录)

[Dynamically / 动态](API.md/#动态)

- [x] [posting news](API.md/#发布动态)
- [x] [get all dynamic list ](API.md/#获取全部动态列表)
- [x] [get my dynamic list](API.md/#获取我的动态列表)
- [x] [get dynamic image ](API.md/#获取动态图片)
- [x] [report ](API.md/#举报)

[Others / 其他](API.md/#发送邮件)

- [x] [send mail ](API.md/#发送邮件)
- [x] [web deployment ](API.md/#网页)
- [x] [custom 404 middleware ](VaporUsage.md/#自定义404)
- [x] [custom access frequency middleware](VaporUsage.md/#自定义访问频率)
- [ ] ...


##### [View ✍️](VaporUsage.md) Some basic usages of Vapor (查看一些基础用法)

<h2 id="用户">用户</h2>

用户相关接口包括登录、注册、修改密码、退出登录。

> 目前用户登录设置的 Token 有效期为 60 * 60 * 24 * 30 

<h3 id="注册">注册</h3>

> users/register

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| account | 是 | string | 账号 |
| password | 是 | string | 密码 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述字段 |
| accessToken | string | 注册成功则返回 Token |

#### 返回示例

```
{
    "status": 0,
    "message": "注册成功",
    "data": {
        "accessToken": "6xETNQp3kyKMZvv1SMOBO_f0L_oYIjm4q8zeGtfEOBg"
    }
}
```



<h3 id="登录">登录</h3>

> users/login

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| account | 是 | string | 账号 |
| password | 是 | string | 密码 |


#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述字段 |
| accessToken | string | 登录成功则返回 Token |

#### 返回示例

```
{
    "status": 0,
    "message": "登录成功",
    "data": {
        "accessToken": "qgdoPf3v9OqaUwBtGlzX69c6Xz-Jqdsm4X7bu-alF-c"
    }
}

```



<h3 id="修改密码">修改密码</h3>

> users/changePassword

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| account | 是 | string | 账号 |
| password | 是 | string | 旧密码 |
| newPassword | 是 | string | 新密码 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述字段 |

#### 返回示例

```
{
    "status": 0,
    "message": "修改成功，请重新登录"
}
```

<h3 id="获取用户信息">获取用户信息</h3>

> users/getUserInfo

##### 请求方式：GET

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 用户 Token |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述字段 |
| userID | string | 用户 ID |
| phone | string | 手机号 |
| location | string | 所在地 |
| id | int | 表id |
| age | int | 年龄 |
| picName | string | 头像图片名称 |
| birthday | string | 出生日 |
| sex | int | 性别,1男 2女 其他未知 |
| nickName | string | 昵称 |

#### 返回示例

```
{
    "status": 0,
    "message": "请求成功",
    "data": {
        "userID": "D1D0CEBC-91B5-47D1-B62A-C2AAC0197343",
        "phone": "13333312312",
        "location": "花果山",
        "id": 1,
        "age": 18,
        "picName": "9fe6d4e771ddde55a60166e1c4688b39.jpg",
        "birthday": "10240301",
        "sex": 3,
        "nickName": "成昆"
    }
}
```




<h3 id="修改用户信息">修改用户信息</h3>

> users/updateInfo

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 用户 Token |
| age | 否 | Int | 年龄 |
| sex | 否 | Int | 性别,1男 2女 0未知 |
| nickName | 否 | string | 昵称 |
| phone | 否 | string | 手机号 |
| birthday | 否 | string | 出生日 |
| location | 否 | string | 位置 |
| picImage | 否 | Data | 用户头像 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述字段 |

#### 返回示例

```
{
    "status": 0,
    "message": "修改成功"
}
```



<h3 id="退出登录">退出登录</h3>

> users/exit

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 登录/注册时接口返回的 AccessToken |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |

#### 返回示例

```
{
    "status": 0,
    "message": "退出成功"
}
```


<h2 id="动态">动态</h2>

动态相关接口，包括发动态、获取全部动态列表、获取动态图片、获取我发布的动态列表、举报等。

> 图片名用 随机数+时间戳 以 md5 编码存储在指定目录。
> 
> 图片大小不能超过 2M 。


<h3 id="发布动态">发布动态</h3>

> record/add

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 用户Token |
| content | 是 | string | 动态内容 |
| title | 是 | string | 动态标题 |
| image | 否 | Data | 上传的图片 |
| county | 是 | string | 动态对应的城市 |


#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |

#### 返回示例

```
{
    "status": 0,
    "message": "发布成功"
}
 
```



<h3 id="获取全部动态列表">获取全部动态列表</h3>


> record/getRecords

##### 请求方式：GET

#### 接口示例

[http://api.jinxiansen.com/record/getRecords?page=0&county=huxian](http://api.jinxiansen.com/record/getRecords?page=0&county=huxian)

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| page | 是 | int | 分页索引，起始为 0 |
| county | 是 | string | 动态对应的城市 |


#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |


#### 返回示例

```
{
    "status": 0,
    "data": [
        {
            "county": "huxian",
            "id": 1,
            "imgName": "6fa5bb4b4a2371c6a6bc83573bb4c558.jpg",
            "title": "身穿道袍戴道冠一道士任景区管理局沙窝村党支部书记",
            "time": "2018-06-17 11:26:50",
            "content": "有一位身着道袍、头戴道冠、手持令牌“做法”的沙窝村共产党员朱新财近日在鄠邑区景区管理局涝峪沙窝村任新一届村党支部书记。\n      《中共中央、国务院关于加强宗教工作的决定》指出：“共产党员不得信仰宗教，要教育党员、干部坚定共产主义信念，防止宗教的侵蚀。对笃信宗教丧失党员条件、利用职权助长宗教狂热的要严肃处理。”\n       2016年4月30日，习总书记在全国宗教工作会议上也明确指出：“共产党员要做坚定的马克思主义无神论者，严守党章规定，坚定理想信念，牢记党的宗旨，绝不能在宗教中寻找自己的价值和信念。”\n       朱新财加入道教多年，多次在涝峪山区，以身穿道袍，头戴法帽，手拿令牌“跳端公”，进行迷信活动，无人不知，无人不晓。其骗取钱财一事曾被户县公安局机关处罚过。不知什么原因今年能被鄠邑区景区管理局党委批准为沙窝村任新一届村党支部书记？\n       此事发生后党员、群众向鄠邑区景区管理局党委、纪委反映无果。\n       西安鄠邑区景区管理局党委应该给党员和群众一个公开的答复。\n       消息来源：户县人民网",
            "userID": "310370D2-65FE-4478-B412-4163CB7DFA5A"
        }
    ],
    "message": "请求成功"
}
 
```

<h3 id="获取动态图片">获取动态图片</h3>

> record/image

##### 请求方式：GET

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| name | 是 | string | |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
|返回一张图片|

#### 接口示例
  
[http://api.jinxiansen.com/record/image?name=be0bf2d70f6bbe05efbe2e89578ba84b.jpg](http://api.jinxiansen.com/record/image?name=be0bf2d70f6bbe05efbe2e89578ba84b.jpg)


<h3 id="获取动态图片二">获取动态图片(2)</h3>

在 URL 后面追加图片名称，见示例

> record/image

##### 请求方式：GET

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| 图片名称 | 是 | string | |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
|返回一张图片|

#### 接口示例
  
[http://api.jinxiansen.com/record/image/be0bf2d70f6bbe05efbe2e89578ba84b.jpg](http://api.jinxiansen.com/record/image/be0bf2d70f6bbe05efbe2e89578ba84b.jpg)



<h3 id="获取我的动态列表">获取我的动态列表</h3>

> record/getMyRecords

##### 请求方式：GET

#### 接口示例

[http://api.jinxiansen.com/record/getMyRecords?page=0&county=huxian&token=DJ_ssuG_vEpnt4te1ho2fK2PqmhPxaSo5B9SoXxnfn4](http://api.jinxiansen.com/record/getMyRecords?page=0&county=huxian&token=DJ_ssuG_vEpnt4te1ho2fK2PqmhPxaSo5B9SoXxnfn4)

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 用户 Token |
| county | 是 | string | 城市 |
| page | 是 | int | 分页索引，由 0 开始 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |
| county | string | 城市 |
| content | string | 内容 |
| userID | string | 用户 ID |
| title | string | 标题 |
| time | string | 发布时间 |

  
#### 返回示例

```
 {
    "status": 0,
    "message": "请求成功",
    "data": [
        {
            "county": "huxian",
            "content": "And to generate the TOC, open the command palette ( Ctrl + Shift + P ) and select the Markdown TOC:Insert/Update option or use Ctrl + M T",
            "userID": "2F2E4E60-4FDF-41C3-AB3A-409A8396ECC2",
            "title": "Markdown TOC",
            "time": "2018-06-18 22:04:52"
        }
    ]
}

```



<h3 id="举报">举报</h3>

> record/report

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 用户 Token |
| content | 是 | string | 举报内容 |
| county | 是 | string | 对应城市 |
| image | 否 | Data | 举报上传的图片 |
| contact | 否 | string | 联系信息 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |

#### 返回示例
  
```
 {
    "status": 0,
    "message": "举报成功"
}
```



<h2 id="发送邮件">发送邮件</h2>

邮件发送请自行配置 SMTP 相关参数。

> sendEmail

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| email | 是 | string | 接收人邮箱 |
| myName | 是 | string | 发送人姓名 |
| subject | 是 | string | 邮件主题 |
| text | 是 | string | 邮件内容 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |

#### 返回示例

```
{
    "status": 0,
    "message": "发送成功"
}
 
```


<h3 id="网页">网页</h3>


这里有几个 Vapor 部署的 H5 页面示例，你可以点击查看效果。

[Keyboard](http://api.jinxiansen.com/h5/keyboard)
[Line](http://api.jinxiansen.com/h5/line)
[Color](http://api.jinxiansen.com/h5/color)
[Reboot](http://api.jinxiansen.com/h5/reboot)
[Loader](http://api.jinxiansen.com/h5/loader)
[Login](http://api.jinxiansen.com/h5/login)


## 反馈

如果有任何问题或建议，可以提一个 [Issue](https://github.com/Jinxiansen/SwiftServerSide-Vapor/issues)，

或联系我：[Jinxiansen](http://jinxiansen.com)。


