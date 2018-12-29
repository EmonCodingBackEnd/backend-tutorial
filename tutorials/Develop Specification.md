# 核心思想

让代码更容易维护、容易扩展、容易阅读，更进一步：

**一年之后，你不会因为新功能、bug修复而骂人或被人骂**

【编写仓促、不断更新、不断完善，希望一起遵守】



# 一、数据库规范

## 1.1 数据库数据类型默认值

| 业务类型 | 数据库类型     |            | 默认值       | 说明                          |
| -------- | -------------- | ---------- | ------------ | ----------------------------- |
| 数量     | int            | Integer    | 依据业务确定 | version,count等               |
| 状态值   | tinyint        | Short      | 依据业务确定 | score,sex,status,type,level等 |
| 字符串   | varchar(n)     | String     | 依据业务确定 | n的取值根据内容长度而定       |
| 表的主键 | bigint         | Long       | 依据业务确定 |                               |
| 金额(高) | decimial(18,4) | BigDecimal | 依据业务确定 | 经过除法计算的，产生高精度    |
| 金额(低) | decimial(18.2) | BigDecimal | 依据业务确定 | 产品金额、合同金额等          |
| 比率     | tinyint        | Integer    | 依据业务确定 | 销售合同分成比例              |
| 日期     | date           | Date       | 依据业务确定 | 如果是日期，只有日期          |
| 时间     | datetime       | Date       | 依据业务确定 | 如果是时间，包含日期和时间    |



## 1.2 数据库特殊字段定义 

- 如果是涉及业务的表，需要有`creator`字段，表示记录的发起者、创建者、修改者、删除者等。
- 所有表都有如下字段（尽可能）
  - `id`   主键
  - `tenant_id`租户ID
  - `org_id` 机构ID
  - `deleted`状态，0-未删除；1-已删除
  - `create_time` 创建时间
  - `modify_time` 更新时间
  - `version` 记录版本号



# 二、编码规范

## 2.1、错误码定义

错误码由6位数字组成： `2位系统` + `2位模块` + `2位业务`

比如： 10（收银宝）+10（商户管理）+10（某一个ServiceImpl）

| 错误码        | 含义 |
| ------------- | ---- |
| 000000/0      | 成功 |
| 10XXXX-99XXXX | 失败 |

## 2.2、异常定义

建议每个系统甚至模块，有自己的异常。

比如，CRM业务异常： CrmException

Crm错误码定义: CrmStatus



## 2.3、业务字典 

`BaseDict`->`系统Dict`，其中`BaseDict`定义共享的Dict和方法，`系统Dict`跟随系统走。

**不允许有其他的字典引用方式，不允许私自提交字典，建议由一个人来提交维护，或各个系统负责人提交**

### 2.3.1、字典的定义

```bash
public interface BaseDict {
    protected Logger log = LoggerFactory.getLogger(RedisCache.class);
    
    interface BaseEnum<T> {
        T getValue();
    }

    /** 根据String值获取枚举实例，如果找不到则返回null. */
    static <T extends BaseEnum> T getByValue(Class<T> enumClazz, String value) {
        for (T each : enumClazz.getEnumConstants()) {
            if (each.getValue().equals(value)) {
                return each;
            }
        }
        return null;
    }

    /** 根据Integer值获取枚举实例，如果找不到则返回null. */
    static <T extends BaseEnum> T getByValue(Class<T> enumClazz, Integer value) {
        for (T each : enumClazz.getEnumConstants()) {
            if (each.getValue().equals(value)) {
                return each;
            }
        }
        return null;
    }

    /** 根据String值获取枚举实例，如果找不到则抛异常. */
    static <T extends BaseEnum> T getByValueNoisy(Class<T> enumClazz, String value) {
        for (T each : enumClazz.getEnumConstants()) {
            if (each.getValue().equals(value)) {
                return each;
            }
        }
        log.error("【字典查询】根据字典值找不到对应字典, enumClazz={}, value={}", enumClazz, value);
        throw new EdenException(EdenStatus.DICT_ENUM_NOT_EXIST);
    }

    /** 根据Integer值获取枚举实例，如果找不到则抛异常. */
    static <T extends BaseEnum> T getByValueNoisy(Class<T> enumClazz, Integer value) {
        for (T each : enumClazz.getEnumConstants()) {
            if (each.getValue().equals(value)) {
                return each;
            }
        }
        log.error("【字典查询】根据字典值找不到对应字典, enumClazz={}, value={}", enumClazz, value);
        throw new EdenException(EdenStatus.DICT_ENUM_NOT_EXIST);
    }
}
```



```bash
package com.ishanshan.eden.constant;

import com.ishanshan.component.cache.redis.RedisCache;
import com.ishanshan.eden.exception.EdenException;
import com.ishanshan.eden.exception.EdenStatus;
import lombok.Getter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.beans.IntrospectionException;
import java.lang.reflect.Field;

public interface CrmDict extend BaseDict {

    /** 是与否；1-是;0-否. */
    interface YesOrNo {
        String NAME = "yes_or_no";
        /** 是. */
        Integer YES = 1;
        /** 否. */
        Integer NO = 0;
    }

    /** 数据是否删除；1-已删除；0-未删除 */
    interface Deleted {
        String NAME = "deleted";
        /** 已删除. */
        Integer YES = 1;
        /** 未删除. */
        Integer NO = 0;
    }

    /** 会员拥有的会员卡赠送状态. */
    enum CustomerCardGiveStatus implements BaseEnum<Integer> {
        /** 无赠送. */
        NO_GIVE_TIMES(0),
        /** 待赠送. */
        TIMES_GIVEING(1),
        /** 已赠送. */
        TIMES_GIVED(2),
        ;

        public static String NAME = "customer_card_give_status";

        CustomerCardGiveStatus(Integer value) {
            this.value = value;
        }

        private Integer value;

        @Override
        public Integer getValue() {
            return value;
        }
    }
    
    
}

```

### 2.3.2、字典的引用

- 示例1：

```bash
        Dict.GoodsSpuStatus spuStatus =
                Dict.getByValue(Dict.GoodsSpuStatus.class, request.getSaleStatus());
        if (spuStatus == null) {
            log.error("【门票新增】上下架状态值不合法, saleStatus={}", request.getSaleStatus());
            throw new EdenException(EdenStatus.GOODS_SALE_STATUS_ERROR);
        }
```

- 示例2

```bash
        if (Dict.AuthType.MOBILE.toString().equals(authType)) {
            authName = "mobile";
        } else if (Dict.AuthType.USERNAME.toString().equals(authType)) {
            authName = "loginname";
        } else if (Dict.AuthType.EMAIL.toString().equals(authType)) {
            authName = "personalEmail";
        } else if (Dict.AuthType.OPENID.toString().equals(authType)) {
            authName = "openid";
        } else {
            throw new EdenException(EdenStatus.AUTH_TYPE_NOT_SUPPORT);
        }
```





## 2.4、业务参数

### 2.4.1、参数的定义

```bash
package com.ishanshan.eden.constant;

public interface Param {

    /** 访客计划提醒的提前时间，单位秒. */
    interface VisitPlanRemindAheadOfTime {
        String NAME = "visit_plan_ramind_ahead_of_time";
    }

    /** 访客计划到访最大延期次数. */
    interface VisitPlanDelayTimes {
        String NAME = "visit_plan_delay_times";
    }

    /** 默认用户头像. */
    interface DefaultAvatar {
        String NAME = "default_avator";
    }

    /** 是否允许重复登录. */
    interface AllowDuplicateLogin {
        String NAME = "allow_duplicate_login";
    }

    /** 门店打印设置. */
    interface ShopPrintSetup {
        String NAME = "shop_print_setup";
    }

    /** 是否显示监控日志. */
    interface ShowWebsiteMonitorLog {
        String NAME = "show_website_monitor_log";
    }
}

```

#### 2.4.2、参数的引用

```bash
            Optional<ParamsItem> paramsItem =
                    RedisParamsCache.queryParams(user.getShopId(), Param.AllowDuplicateLogin.NAME);
            if (paramsItem.isPresent()
                    && Dict.YesOrNo.NO.toString().equals(paramsItem.get().getValue())) {
                String redisKey = JwtRedisKeyUtil.getRedisKeyByUsername(userDetails.getUsername());
                if (stringRedisTemplate.opsForValue().getOperations().hasKey(redisKey)) {
                    String userId = stringRedisTemplate.opsForValue().get(redisKey);
                    LoginSession loginSession = redisCache.userSession(Long.valueOf(userId));
                    logger.debug(String.format("【用户登录】用户已登录或未正常退出, user=%s", loginSession.toLog()));
                    throw new LockedException("用户已登录或未正常退出，请使用短信验证码强制登录");
                }
            }
```

## 2.5、正则的使用

建议正则表达式统一定义：

### 2.5.1、正则的定义

```bash
package com.ishanshan.component.regex;

import java.util.regex.Pattern;

public abstract class RegexDefine {

    /**
     * 用户手机号正则表达式定义.
     *
     * <p>创建时间: <font style="color:#00FFFF">20180424 15:41</font><br>
     *
     * <p>匹配校验手机号的合法性，并能获取手机号开头3个数字，与尾号4个数字
     *
     * <p>正则：手机号（精确）
     *
     * <p>移动：134(0-8)、135、136、137、138、139、147、150、151、152、157、158、159、178、182、183、184、187、188、198
     *
     * <p>联通：130、131、132、145、155、156、175、176、185、186、166
     *
     * <p>电信：133、153、173、177、180、181、189、199
     *
     * <p>全球星：1349
     *
     * <p>虚拟运营商：170
     *
     * <ul>
     *   <li>正则：^((?:13[0-9])|(?:14[5|7])|(?:15(?:[0-3]|[5-9]))|(?:17[013678])|(?:18[0,5-9]))\d{4}(\d{4})$
     *   <li>定义：11位手机号码
     *   <li>示例：18767188240
     * </ul>
     *
     * @since 1.0.0
     */
    public static final String MOBILE_REGEX =
            "^((?:13[0-9])|(?:14[5|7|9])|(?:15(?:[0-3]|[5-9]))|(?:16[6])|(?:17[013678])|(?:18[0-9])|(?:19[89]))\\d{4}(\\d{4})$";
            
    /** 字段说明：{@linkplain #MOBILE_REGEX}. */
    public static final Pattern MOBILE_REGEX_PATTERN = Pattern.compile(MOBILE_REGEX);
    
}

```

### 2.5.2、正则的引用

- 高级引用

```bash
    @Test
    public void matchMobile() throws Exception {
        String mobileValue = "18767188240";
        Pattern mobilePattern = RegexDefine.MOBILE_REGEX_PATTERN;
        Matcher mobileMatcher = mobilePattern.matcher(mobileValue);
        if (mobileMatcher.matches()) {
            System.out.println(RegexDefine.MOBILE_REGEX);
            for (int i = 0; i <= mobileMatcher.groupCount(); i++) {
                System.out.println(String.format("group(%d)=%s", i, mobileMatcher.group(i)));
            }
        }
    }
```

- 低级引用

```bash
        if (!RegexDefine.MULTI_IDS_REGEX_PATTERN.matcher(menuIds).matches()) {
            log.error("【菜单删除】格式不合法,请输入英文逗号分隔的菜单ID串, menuIds={}", menuIds);
            throw new EdenException(EdenStatus.MENU_IDS_INVALID);
        }
```

## 2.6、Redis使用规范

### 2.6.1、key命名约定

- 命名组成

key=`系统名:服务名:用途:数据类型:业务值`

示例1：`eden:user:token:string:<username>`

示例2：`eden:user:cache:hash:<user>`

示例3：`eden:order:lock:string:<order_id>`

- key采用小写结构，不采用驼峰命名方式；中间可以用下划线`_`连接

示例1：`saas_eden:order:lock:string:<order_id>`

- key的长度限制在128字节之内，既可以节省空间，又可以加快查询速度

### 2.6.2、设置有效期

- key要设置过期时间
- 对于key有效期比较长的特殊场景，要有主动清除redis key的机制：比如调用API，以便应对突发情况下清理缓存

### 2.6.3、缓存数据管理

- 使用Cache Aside缓存模式进行操作

### 2.6.4、其他

- 对于必须要存储的大文本数据一定要压缩后存储

对于大文本【超过500字节】写入到Redis时，一定要压缩存储。

大文本数据存入Redis，除了带来极大的内存占用外，在访问量高时，很容易就会将网卡流量占满，进而造成整个服务器上的所有服务不可用，并引发雪崩效应，造成各个系统瘫痪！



## 2.7、常量

一切的一切，字典、正则、参数之外的引用，通过常量。

```bash
package com.ishanshan.eden.constant;

import java.math.BigDecimal;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * 用来定义非Dict，非Rule，非Param之外的常量.
 *
 * <p>创建时间: <font style="color:#00FFFF">20180821 11:47</font><br>
 * [请在此输入功能详述]
 *
 * @author Rushing0711
 * @version 1.0.0
 * @since 1.0.0
 */
public interface Constant {

    DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    DateTimeFormatter DATETIME_FORMATTE = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    DateTimeFormatter DATE_FORMATTER_SHORT = DateTimeFormatter.ofPattern("yyyyMMdd");
    DateTimeFormatter DATETIME_FORMATTER_SHORT = DateTimeFormatter.ofPattern("yyyyMMdd HH:mm:ss");

    /** 散客信息. */
    interface C_GUEST {
        Long ID = 1052018110700000000L;
        String NAME = "散客";
    }

    /** 获取租户的默认收银员/核销员ID. */
    static Long getCashierByTenantId(Long tenantId) {
        return tenantId * 10000;
    }

    /** 获取当日门店核核销量统计的 当日门店组合串. */
    static String getWorkdateShopId(Long shopId) {
        return LocalDate.now()
                .format(DATE_FORMATTER_SHORT)
                .concat(C_COMMON.UNDERLINE)
                .concat(String.valueOf(shopId));
    }

    interface C_COMMON {
        /** 系统名称 */
        String SYSTEM_NAME = "EDEN";

        /** 系统中使用到的默认编码 */
        Charset DEFAULT_CHARSET = StandardCharsets.UTF_8;

        String ADMIN = "admin";

        /** 平台层次的租户ID. */
        Long TOP_TENANT_ID = 10000L;

        /** 平台层次的总部门店ID. */
        Long TOP_SHOP_ID = 1000010000L;

        /** 平台层次的虚拟门店. */
        Long TOP_VIRTUAL_SHOP_ID = 10000L;

        /** 平台层次的商品品牌. */
        Long TOP_BRAND_ID = 10000L;

        /** 层级关系中，最顶层的记录，parent_id的取值. */
        Long TOP_PARENT_ID = 0L;

        /** 用户登录初始密码 */
        String PASS_WORD_NUM = "123456";

        /** 层级关系中，同层排序值sort的初始值. */
        Integer TOP_SORT_ORDER = 1;

        Integer INTEGER_ZERO = 0;
        Integer INTEGER_ONE = 1;
        Integer INTEGER_TWO = 2;
        Long LONG_ZERO = 0L;
        Long LONG_ONE = 1L;
        Boolean BOOLEAN_TRUE = true;
        Boolean BOOLEAN_FALSE = false;
        BigDecimal DECIMAL_ZERO = BigDecimal.ZERO;

        /** 排序 */
        String ASC = "asc";

        String DESC = "desc";

        /** 逗号. */
        String COMMA = ",";

        /** 冒号. */
        String COLON = ":";

        /** 下划线. */
        String UNDERLINE = "_";

        /** 空字符串. */
        String EMPTY = "";

        String TRANSVERSE = "-";

        /** 文件夹分隔符或者默认斜杠分隔符. */
        String FOLDER_SEPARATOR = "/";
    }

    abstract class C_SMS {
        /** 发送验证码 */
        public static String SEND_VERIFY_CODE = "SMS_152283583";

        public static String USER_ID;
        public static String PASSWORD;
        public static String GATE_URL;
    }

    abstract class C_PAY {
        /** 网商交易请求地址 */
        public static String HTTPSURL;

        /** 乐园网商支付参数 */
        public static String APPID = "1060717408233938945";

        public static String KEY = "hhaq9zdh9obdc74evx5l7ld4o2sd30af";
        public static String WS = "WS";
        public static String SUBJECT = "乐园收银台商品支付";

        // 支付宝
        public static String ALI = "ALI";
        // 微信
        public static String WX = "WX";
    }
}

```





