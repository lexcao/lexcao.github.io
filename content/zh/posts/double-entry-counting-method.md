---
title: 「翻译」复式记账法 (The Double-Entry Counting Method)
date: 2023-07-04
tags: [ Accounting, Translation ]
---

翻译自 [*The Double-Entry Counting Method*](https://beancount.github.io/docs/the_double_entry_counting_method.html)

# 介绍

本文是一份关于复式记账的简要介绍，从计算机科学家的角度撰写。它试图以尽可能简单的方法解释基础记账，简化会计中通常涉及到的某些特殊性。它也代表了 [Beancount](http://furius.ca/beancount/) 的工作方式，并且对所有使用纯文本记账的用户都应该适用。

请注意，我不是会计师，在编写此文档过程中，我可能使用与传统会计培训教授略有不同或不常见的术语。我给自己授权创造一些新的、甚至是不寻常的东西，以便将这些想法尽可能简单明了地解释给那些对它们不熟悉的人。

我认为每个高中生都应该在高中阶段学习复式记账法，因为这是一项极其有用的组织技能，并且我希望这篇文章可以帮助将其知识传播到专业圈以外的领域。

# 复式记账的基础

复式记账法只是一种简单的计数方法，只有一些简单的规则。

让我们从定义账户的概念开始。账户是一种可以容纳物品的东西，就像一个袋子。它用于计算和累积物品。让我们画一条水平箭头来直观地表示随着时间推移账户中不断变化的内容：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/2f37aa3938d599d4783ca9b74965026fba0a3b50.png#center)

左侧，是描述过去，而右侧则是不断增长的时间：现在、未来等。

现在，让我们假设账户只能包含一种东西，例如美元。所有的账户都以零美元的空内容开始。我们将称账户中单位数量为账户的 **余额 （Balance）**。请注意，它代表了特定时间点上其内容的情况。我会使用一个数字在帐户时间轴上方绘制余额：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/54633827be99c315dc937778221752b848411ca9.png#center)

账户的内容会随着时间而变化。为了改变账户的内容，我们必须向其添加一些东西。我们将这个添加称为对账户的记账，我会在该账户的时间轴上画一个带圈数字来表示这种变化，例如：向该账户中添加 100 美元：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/004bc3354eb84bf554a8e5080a21f8d16fc29d82.png#center)

现在，我们可以在记账后绘制更新后的账户余额，并在其后面加上另一个小数字：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/6281f96c3465982c6bf48fccb302b40f90890311.png#center)

账户加上 100 美元后，余额现在为 100 美元。

我们也可以从账户中减去一定金额。例如，我们可以减去 25 美元，这样账户余额就变成了 75 美元：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/1672e121ec80f8fcdb158bb497e05e6dc809dee5.png#center)

如果我们减去的金额超过账户余额，账户余额也可能变为负数。例如，如果我们从该账户中取出 200 美元，则余额现在变为 -125 美元：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/862c0b57a35631a52eead2cf8cdd7b5f2a1aa106.png#center)

账户中包含负数是完全正常的。请记住，我们所做的只是计数。很快我们会看到，有些账户在它们的时间轴上将保持负余额。

## 报表 （Statement）

值得注意的是，我在前一节中写下的时间线记账与机构为每个客户维护并通常通过邮件发送的纸质账户报表类似：

| 时间         | 描述     | 金额      | 余额      |
|------------|--------|---------|---------|
| 2016-10-02 | …      | 100.00  | 1100.00 |
| 2016-10-05 | ..     | -25.00  | 1075.00 |
| 2016-10-06 | ..     | -200.00 | 875.00  |
| 最终结余       | 875.00 |         |         |

有时候金额栏会被分成两个，一个显示正数，另一个显示负数：

| 时间         | 描述     | 扣款 （Debit） | 入账 （Credit） | 余额 （Balance） |
|------------|--------|------------|-------------|--------------|
| 2016-10-02 | …      |            | 100.00      | 1100.00      |
| 2016-10-05 | ..     | 25.00      |             | 1075.00      |
| 2016-10-06 | ..     | 200.00     |             | 875.00       |
| 最终结余       | 875.00 |            |             |              |

在这里，“扣款 （Debit）” 表示 “从你的账户中扣除”，而 “入账 （Credit）” 表示 “存入你的账户”。有时会使用词语 “取款 （Withdrawals）” 和 “存款 （Deposits）”。这完全取决于上下文：对于支票和储蓄账户，通常会有两种类型的记账，但对于信用卡账户来说，通常只显示正数，然后偶尔进行月度付款，因此使用单列格式。 【译者注：这里 Debit 和 Credit 可以翻译为 借方 （Debit） 和 贷方 （Credit），这里为了更好的理解金钱的流向，使用带有方向意味的词】

无论如何，“余额” 栏始终显示账户在金额记入后的结余。有时，对账单按时间倒序呈现。

## 单式记账

在这个故事中，这个账户属于某个人。我们将称呼此人为账户所有者。该账户可以用来代表现实世界中的一个账户，例如，想象一下我们使用它来代表银行里所有者支票账户的内容。因此，我们将通过给它命名来标记该帐户，在本例中为 “支票 （Checking）”：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/a4ac6f0f3d2cf7df150fd501f0ab9a5942f79a80.png#center)

想象一下，某个时刻，这个账户的余额为 1,000 美元，就像我在图上画的那样。现在，如果所有者从这个账户中花费了 79 美元，我们会用以下方式表示：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/75337406afb5f23c23733fd25be8683ae151b410.png#center)

此外，如果支出是在 餐厅 （Restaurant） 用餐产生的，我们可以使用一个类别标记来指示这笔记账的用途。比如说，“餐厅”，就像这样：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/d7f6ec08cb13d409752000bb42495399abc85848.png#center)

现在，如果我们有很多这样的记账，我们可以编写一个计算机程序来累积每个类别的所有更改，并为它们中的每一个计算总和。例如，这将告诉我们总共在餐馆花费了多少钱。这被称为单式记账法。

但我们不会这样做，我们有更好的方法。请再耐心等待几个章节。

## 复式记账

一个所有者可能有多个账户。我将通过在同一张图上绘制许多类似的账户时间线来表示这一点。与以前一样它们带有唯一的名称标签。假设所有者有与之前相同的 “支票 （Checking）” 账户，并且现在还有一个 “餐厅 （Restaurant）” 账户，可以用于累积在餐厅消费的所有用餐开销。它看起来像这样：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/3088280515ab5b6da599edd5a1b2ca30100f2b0b.png#center)

现在，我们可以不像之前那样将记账归类为 “餐厅类别”，而是创建一个匹配的记账在 “餐厅” 账户上记录我们花费了多少钱用于用餐，金额为 79 美元：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/3088280515ab5b6da599edd5a1b2ca30100f2b0b.png#center)

“餐厅” 账户和其他账户一样，也有一个累积余额，因此我们可以了解到我们在 “餐厅” 总共花费了多少。这与计算支票账户中的变化完全对称。

现在，我们可以通过创建一种称为 “交易 （Transaction）” 的对象来将这两个记账关联起来，从而形成一种父级框。

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/18524adffedac5e812eb65dcbb179b66b0ae9e53.png#center)

请注意，我们还将 “在 Uncle Boons 吃晚餐” 与此交易关联起来。一笔交易也有一个日期，它的所有记账都记录在该日期发生。我们称之为交易日期。

现在我们可以介绍复式记账系统的基本规则：

```
一笔交易的所有账目之和必须等于零。

The sum of all the postings of a transaction must equal zero.
```

记住这一点，因为这是复式记账法的基础和最重要的特征。有着重要的后果，我将在本文稍后讨论。

在我们的例子中，我们从支票账户扣除 79 美元，并将其 “转移” 到餐厅账户。`(79) + (-79) = 0`。 为了强调这一点，我在交易的记账下面画一个小求和线，就像这样：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/a56ad72219b0d8a6c90c692655d1b24459add2d6.png#center)

## 许多账户

可能会有许多这样的交易，涉及许多不同的账户。例如，如果账户所有者第二天用信用卡支付了午餐费用，则可以通过创建一个 “信用卡 （Credit card）” 账户来表示，并具有相应的交易来跟踪现实世界中的信用卡余额：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/458909db06c7f38f7896205f67d60397b292e7d9.png#center)

在这个例子中，所有者在一家名为 “Eataly” 的餐厅花费了 35 美元。所有者的信用卡之前的余额是 -450 美元；支出后，新余额为 -485 美元。

对于每个真实世界的账户，所有者都可以像我们一样创建一个记账账户。此外，对于每种支出类别，所有者还会创建一个记账账户。在这个系统中，可以创建无限数量的账户。

请注意，示例中的余额是负数；这不是错误。信用卡账户的余额通常为负数：它们代表你欠银行的金额，银行在信用上向你提供了借款。当你的信用卡公司跟踪你的支出时，从他们自己的角度写出对账单，并将其表示为正数。对于你来说，这些都是最终需要支付的金额。但在我们的记账系统中，在所有者的角度下表示数字，在他看来，这是他欠下的而不是拥有的钱。而他有的是一顿饭（“餐厅” 正数）。

## 多次记账

最后，交易可能有超过两个的记账；事实上，它们可以有任意数量的记账。唯一重要的是它们金额之和为零（根据上述复式记账规则）。

例如，让我们看看如果所有者在 12 月份发了工资会发生什么：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/ce1cc8d6be9b3de0868a301b333df0a67997f447.png#center)


这个例子中他的总工资记录为 -2,905 美元（稍后我会解释符号）。其中 905 美元用于缴税。他的 “净” 工资是剩下的 2,000 美元，存入了他的“支票账户”，导致该账户余额为 2,921 美元（之前的余额为 921 + 2,000 = 2,921）。此交易有三个记账：`(+2000) + (-2905) + (+ 905) = 0`。遵守复式记账规则。

现在，你可能会问：为什么他的工资记录为负数？这里的推理与上面的信用卡类似，尽管可能更微妙一些。这些账户存在是为了从所有者的角度跟踪所有金额。所有者提供工作，并以此换取金钱和税收（正数）。所提供的工作以美元单位计价。它 “离开” 了所有者（想象一下，所有者口袋里存放着潜在的工作，在每天上班时将潜在的工作交给公司）。 所有者付出了价值 2905 美元的劳动力。我们想要追踪给出了多少劳动力，并且使用 “薪水” 账户来完成。那就是他总薪水。

请注意，为了保持简单，我们已经简化了这个工资支出交易。更真实的薪水记录会有更多的账户；我们将分别核算州税和联邦税额，以及社会保障和医疗保险支付、扣除、通过工作支付的保险费和在该期间内累计的休假时间。但它不会更加复杂：所有金额都可以从他的工资单中转换成一个具有更多记账的单一交易。结构仍然相似。

# 账户类型

现在让我们转向所有者可以拥有的不同类型的账户。

余额或差额。首先，账户之间最重要的区别在于我们是否关心特定时间点的余额，还是只关心一段时间内的差异。例如，某人支票或储蓄账户的余额是一个有意义的数字，所有者和相应银行都会关注它。同样地，某人信用卡账户上欠款总额也很重要。对于房屋贷款剩余还款金额也是如此。

另一方面，某人自出生以来的餐厅支出总额并不特别感兴趣。对于这个账户，我们可能关心的是在特定时间段内发生的餐厅支出金额。例如，“上个月你在餐馆花了多少钱？”或者上季度、去年等。同样地，某人几年前开始在公司工作以来所获得的总薪资收入并不重要。但我们会关心一个税务年度内所赚取的总收入，因为它用于向税务部门报告自己的收入。

- 在某一时间点上余额有意义的账户称为**资产负债表账户**。这类账户分为两种类型：<br>“**资产 （Assets）**” 和 “**负债 （Liabilities）**”。

- 另外一些账户，也就是那些余额并不特别重要但我们有兴趣计算一段时间内变化的账户被称为<br>**损益表账户**。同样地，它们分为两种：“**收入 （Income）**” 和 “**支出 （Expenses）**”。

普通符号。其次，我们考虑账户余额的常规标记。复式记账法绝大多数账户的余额往往具有始终为正或始终为负的符号（尽管如前所述，一个账户的余额可能会改变符号）。这就是我们将区分上述几对帐户的方式：

- 对于资产负债表账户，资产通常具有正余额，而负债通常具有负余额。

- 对于损益表账户，支出通常具有正余额，而收入通常具有负余额。

总结为以下表格：

|                                     | 余额：正（+）         | 余额：负（-）            |
|-------------------------------------|-----------------|--------------------|
| 在某一时间点上<br/>**余额数额**很重要<br/>（资产负债表） | 资产<br/>Assets   | 负债<br/>Liabilities |
| 随着时间的推移<br/>**余额变化**很重要<br/>（损益表）   | 支出<br/>Expenses | 收入<br/>Income      |

让我们讨论每种类型的账户并提供一些案例，这样它就不会太抽象。

- **资产 （Assets +）** 资产账户代表所有者拥有的东西。一个典型的例子是银行账户。另一个例子是“现金 （Cash） ”账户，它记录你钱包里有多少钱。投资也是资产（在这种情况下，它们的单位不是美元，而是某些共同基金或股票的一定数量份额）。最后，如果你拥有一所房屋，则该房屋本身被视为一项资产（其市场价值随时间波动）。

- **负债 （Liabilities -）** 负债账户代表所有者所欠的东西。最常见的例子是信用卡。同样，银行提供的对账单会显示正数，但从你自己的角度来看，它们是负数。贷款也是一种负债账户。例如，如果你在房屋上抵押了一笔抵押贷款，则这是你欠下的钱，并通过一个带有负金额的帐户来跟踪。随着每个月偿还按揭付款，这个数字会增加（即其绝对值随时间变小而变小，例如 -120,000 > -117,345）。

- **支出 （Expenses +）** 支出账户代表你已经收到的某些东西，可能是通过交换其他物品来购买的。这种类型的账户似乎很自然：食物、饮料、服装、租金、航班、酒店和大多数其他通常支配收入所花费的类别。然而，税款也通常由一个支出账户跟踪：当你获得一些工资收入时，源头扣除的税款金额会立即记录为一笔支出。把它看作是支付你在整年中享受到的政府服务。

- **收入 （Income -）** 收入账户用于计算你为了获得其他东西（通常是资产或费用）而放弃的某些东西的价值。对于大多数有工作的人来说，这就是他们时间的价值（薪水收入）。具体来说，在这里我们谈论的是总收入。例如，如果你每年赚取 12 万美元的薪水，那个数字就是 12 万美元，而不是支付税款后剩余的金额。其他类型的收入包括从投资中获得的股息或债券利息支出等。还有一些奇怪的事情可以被记录为收入，比如从信用卡返现或某人送给你礼物等所得到回报价值。

在 Beancount 中，所有的账户名称都必须与之前描述过的账户类型之一相关联。由于一个账户的类型在其生命周期内永远不会改变，因此我们将其类型作为前缀，并按照惯例将其作为帐户名称的一部分。例如，餐厅的合格帐户名称将是 `Expenses:Restaurant`。对于银行支票账户，合格帐户名称将是 `Assets:Checking`。

除此之外，你可以为你的账户选择任何喜欢的名称。你可以创建尽可能多的账户，并且正如我们稍后将看到的那样，你可以按层次结构组织它们。截至本文撰写时，我使用了超过 700 个账户来跟踪我的个人交易。

现在让我们回顾一下我们的例子，并添加更多账户：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/281c7a6ed22a8168fc1094a1faa61f2b0fdd7ca3.png#center)

假设还有更多的交易：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/e3008a34f9ce7a224e33d4cbb79bcebbb08d418e.png#center)

… 甚至更多：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/18b769f7a3cdf7fd67a983d3a39325b563d8d346.png#center)

最后，我们可以通过在账户名称前加上类型来为这些账户中的每一个标记出四种不同的账户类型：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/1f84bcb0ad4787659c157280f6f4ae5ea720482d.png#center)

一个追踪个人交易的真实账本可能每年包含数千笔交易。但原则仍然简单且相同：在一段时间内将记账应用于账户，并必须将其归属到交易中，在此交易中，所有记账的总和为零。

当你为一组账户记账时，实质上是在描述所有帐户随时间发生的所有记账，受规则约束。你正在创建这些记账的数据库。你正在 “记账”，即传统意义上所有交易的账本。有些人称之为 “维护日志”。

我们现在将把注意力转向从这些数据中获取有用信息，总结账本中的信息。

# 试算平衡表 （Trail Balance）

以我们上一个例子为例：我们可以轻松地重新排列所有账户，使得所有资产账户出现在顶部，然后是所有负债账户、收入账户和最后是支出账户。我们只是改变了顺序而没有修改交易结构，以便将每种类型的帐户分组在一起：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/175f3223735d9d04b2a7e3f421bc6280f3cda5eb.png#center)

我们重新排列了账户，资产账户位于顶部分组，然后是负债账户，接着是一些权益 （Equity）账户（我们刚刚引入这个账户，更多内容将在后面讨论），然后是收入和最后底部的支出。

如果我们将所有账户的记账汇总，并仅呈现账户名称及在右侧的最终余额，我们就可以得到一份报告，称为 “试算平衡表 （Trial balance）”。

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/71edc0da7e156b4e07cd6f4f0addded7f15cb33e.png#center)

这仅仅反映了特定时间点上每个账户的余额。由于每个账户最初都是零余额，并且每笔交易本身也有一个零余额，因此我们知道所有这些余额的总和必须等于零 [^1]。这是我们限制每次记账都必须作为一笔交易的结果，以及确保每笔交易都有相互抵消的记账所导致的。

# 损益表 （Income Statement）

从交易列表中提取的一种常见信息是特定时间段内收入账户变化的摘要。这告诉我们在此期间赚了多少钱和花了多少钱，差额告诉我们产生了多少利润（或亏损）。称为 “净收入 （Net income）”。

为了生成这个摘要，我们只需关注收入和支出类型的账户余额，仅汇总特定期间的交易，并将收入余额绘制在左侧，支出余额绘制在右侧：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/6d57026ecb4c28873f77167eb49ea8025bbf150b.png#center)

重要提示：这里的收入数字是负数，支出数字是正数。因此，如果你赚的比花费多（一个好结果），最终的收入 + 支出余额总和将为负数。像任何其他收入一样，净收入有一个负数意味着相应数量的资产和/或负债是正数（这对你有利）。

一个损益表告诉我们在特定时间段内发生了什么变化。公司通常每季度向投资者和公众（如果它们是上市公司）报告这些信息，以分享他们能够赚取多少利润。个人通常会在其年度纳税申报中报告此类信息。

# 清算收入 （Clearing Income）

注意在损益表中，只有特定时间间隔内的交易被汇总。这使得我们可以计算出一年内所有收入的总和。如果我们将自账户创建以来的所有交易相加，就可以得到自账户创建以来所获得的全部收入。

实现同样效果的更好方法是将收入和支出账户的余额清零。Beancount 将此基本转换称为 “清算 （Clearing）[^2]“。它通过以下方式进行：

1. 从时间开始到报告期开始计算这些账户的余额。例如，如果你在 2000 年创建了你的账户，并且想要为 2016 年生成一份收入报表，那么你需要将 2000 年至 2016 年 1 月 1 日之间的余额汇总。

2. 将交易插入以清空这些余额并将它们转移到不是收入也不是支出的其他帐户。例如，如果餐厅支出账户在那 16 年中总计为 85,321 美元，则会插入一笔金额为 -85,321 的交易到餐厅，并向 “上期收益 （Previous earnings）” 添加 +85,321 美元。这些交易日期应为 2016 年 1 月 1 日。包括此交易，在该日期该账户的总和将为零。这就是我们想要的。

所有收入账户插入的交易如下图绿色所示。现在将整个交易相加到总账末尾，只会得出 2016 年期间的变化，因为当时余额为零：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/7f10adb5a661d0aa0b66f5f66aafb3ff5eefa212.png#center)

这就是 bean-query shell 中的 `CLEAR` 操作的语义。

（请注意，对于损益表账户实现相同目的的另一种方法是仅针对清算日期后的交易进行金额分离和计数；但是，联合报告损益表账户和资产负债表账户将导致资产负债表账户出现错误余额。）

# 股权 （Equity）

接收先前累计收入的帐户称为 “上期收益 （Previous earnings） ”。它位于第五种也是最后一种类型的账户中：股权 （Equity）。我们之前没有讨论过这种类型的账户，因为它们通常只用于转移金额以建立报告，并且所有者通常不会对这些类型账户的更改进行记账；软件会自动执行此操作，例如在结算净收入时。

“股权” 账户类型用于保存所有过去活动所涉及的净收入总结。这样做的目的是，如果我们现在将资产、负债和股权账户列在一起，因为收入和支出账户已经清零，所有这些余额的总和应该恰好等于零。而对所有股权账户求和明确告诉我们，在实体中我们持有多少份额，换句话说，如果你用资产来支付所有负债，企业还剩下多少，价值是多少。

请注意，股权账户的正常符号为负数。这并没有特别的含义，只是它们用于抵消资产和负债，如果所有者有任何价值，则该数字应为负数。（负股权意味着一些积极净值。）

这些是在 Beancount 中使用的一些不同的权益账户：

- **上期收益 （Previous Earnings）**或**留存收益 （Retained Earnings）**。这是一个账户，用于保存从时间开始到报告期开始的总收入和支出余额。这就是我们在上一节中提到的账户。

- **当前收益 （Current Earnings）**，也称为**净收入 （Net Income）**。这是一个账户，用于包含报告期间发生的收入和支出余额之和。在报告期结束时，“清算”收入和支出账户后填写。

- **期初余额 （Opening Balances）**。一种股权账户，抵消用于初始化账户的存款。当我们截断过去的交易历史记录，但也需要确保一个帐户的余额以特定金额开始其历史时，就会使用此类帐户。

再次强调：你不需要定义或使用这些账户，因为它们是为了总结交易而创建的。通常情况下，这些账户由上述清算过程填写，或者通过 Pad 指令填写到 “期初余额” 股权账户中，以记录过去的汇总余额。它们由软件自动创建和填充。在接下来的章节中我们将看到如何使用它们。

# 资产负债表 （Balance Sheet）

另一种摘要是列出所有账户的所有者资产和债务清单。这回答了一个问题：“钱在哪里？”理论上，我们可以只关注资产和负债账户，并将其编制成报告：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/093cd8751f07c38e909b7621675daa80db8fb634.png#center)

然而，在实践中，还有一个紧密相关的问题会出现，并且通常同时回答：“一旦所有债务都偿清，我们剩下多少钱？”这被称为**净资产价值 （Net worth）**【译者注：简称净值】。

如果收入和支出账户已经清零，并且它们的余额已转移到股权账户，则净值应等于所有股权账户的总和。因此，在编制资产负债表时，习惯上要清除净收益，然后显示股权账户的余额。报告如下：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/d495b61bc719ab90cdfc9fd379ef62531cff0627.png#center)

请注意，资产负债表可以在任何时间点绘制，只需截断特定日期后的交易列表即可。资产负债表显示某个日期的余额快照；而利润表显示两个日期之间这些余额的差异。

# 总结

将过去的交易历史总结为一个等效存款是很有用的。例如，如果我们对 2016 年某个账户的交易感兴趣，该账户在 2016 年 1 月 1 日时余额为 450 美元，则可以删除所有以前的交易，并用一笔单独的交易替换它们，在 2015 年 12 月 31 日存入 450 美元并从其他地方取出。

那个地方将是股权账户的期初余额。首先，我们可以为所有资产和负债账户（请参见蓝色交易）执行此操作：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/035eb15afa1439450886d6ce20c60013227283b7.png#center)

然后我们删除所有在开户日期之前的交易，以获得一个截断的交易列表：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/2596047a5cbd9da8a925c7a7ee10fef9681ce472.png#center)

当我们专注于特定时间间隔的交易时，这是一个有用的操作。

（这是一些实现细节：这些操作与 Beancount 的设计有关。为了避免使用参数进行所有报告操作，它的所有报告程序都被简化，替代为在整个交易流上运行；通过这种方式，我们将交易列表转换为仅包含要报告的数据。在本例中，汇总只是一个接受完整交易集并返回等效截断流的转换。然后，可以从此交易流中生成不包括过去交易的记账。从程序设计的角度来看，这是很有吸引力的，因为程序的唯一状态是交易流，而且它永远不会直接被修改。这很简单和健壮。）

# 期间报告 （Period Reporting）

现在我们知道，通过清算和仅查看收入和支出账户可以制作一份一段时间内的变动报告（损益表）。 我们还知道，可以进行结算以在任何时间点生成资产、负债和所有者权益的快照（资产负债表）。

更一般地说，我们有兴趣检查一个特定的时间段。这意味着需要一个收入报表，还需要两个资产负债表：期初资产负债表和期末资产负债表。

为了做到这一点，我们采用以下转换：

- 开户 （Open）。我们首先在期初清算净收入，将所有以前的收入余额转移至股权上期收益账户。然后我们总结到期初。我们称清算 + 总结的组合为 “开户”。

- 结帐 （Close）。我们还会截断报告期结束后的所有交易。我们称这个操作为 “结账”。

这是 bean-query shell [^3] 的 “OPEN” 和 “CLOSE” 操作的含义。最终的交易集应该如下所示。

“结帐” 包括两个步骤。首先，我们会移除所有在结束日期之后的交易：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/e9bbbbdf2a94fe681fd547cf470c4d19ae1e6c0e.png#center)

我们可以处理这一笔交易流来生成该期间的损益表。

然后，在所需报告的结束日期再次进行结算，但这次我们将净收入结算到 `Equity:Earnings:Current` 账户：

![Untitled](https://beancount.github.io/docs/the_double_entry_counting_method/media/1dc844e93000faa184bd3e1ec3e0cd4e1a9fb5fb.png#center)

从这些交易中，我们在期末制作资产负债表。

这概括了使用 Beancount 准备交易流以生成报告的操作，以及对这些类型报告的基本介绍。

# 账户表

新用户经常会想知道他们在账户名称中应该使用多少细节。例如，是否应该在账户名称本身中包含收款人，就像这些示例一样？

```
Expenses:Phone:Mobile:VerizonWireless
Assets:AccountsReceivable:Clients:AcmeInc
```

或者应该使用更简单的名称，而依靠“收款人”、“标签”或其他元数据来分组记账？

```
Expenses:Phone
Assets:AccountsReceivable
```

答案是取决于你。这是一个任意的选择。这是个品味问题。我个人喜欢滥用账户名并创建长而具有描述性的名称，其他人则更喜欢保持简单，并使用标签来分组他们的记账。有时候甚至不需要过滤记账的子分组。没有正确答案，这取决于你想做什么。

需要记住的一点是，账户名称隐含地定义了一个层次结构。某些报告代码会解释 “:” 分隔符以创建内存树，并允许你折叠节点的子帐户并计算父级上的聚合值。将其视为一种额外的分组方式。

## 国家-机构 约定

我想出了一个对我的资产、负债和收入账户非常有效的约定，即以该账户所在国家的代码为根，后跟相应机构的简短字符串。在此之下，是该机构中特定账户的唯一名称。就像这样：

```
<type> : <country> : <institution> : <account>
```

例如：可以选择将支票账户命名为 `Assets:US:BofA:Checking` ，其中 “BofA” 代表 “Bank of America“（美国银行）。信用卡账户可以包括特定类型的卡名称作为账户名称，比如 `Liabilities:US:Amex:Platinum` ，如果你有多张卡片，则这样做很有用。

我发现对于支出账户来说，使用这种方案并不合理，因为它们往往代表着通用类别。对于这些账户，按照类别分组似乎更有意义，例如使用 `Expenses:Food:Restaurant`
而不是仅仅使用 `Expenses:Restaurant`。

无论如何，Beancount 除了根账户外不强制执行任何规定；这只是一个建议，这个约定在软件中没有编码。你有很大的自由来尝试实验，并且可以通过处理文本文件轻松更改所有名称。请参阅食谱（[Cookbook](https://beancount.github.io/docs/command_line_accounting_cookbook.html)）以获取更多实用指南。

# 贷方和借方 （Credits & Debits）

目前为止，我们还没有讨论 “借方 （Credits）” 和 “贷方 （Debits）” 的概念。这是有意的：Beancount 基本上摒弃了这些概念，因为它使其他所有事情变得更简单。我认为仅需学习收入、负债和权益账户的符号通常是负数，并以相同方式处理所有账户比使用借方和贷方术语并对不同类别的账户进行不同处理要简单得多。无论如何，本节将解释这些内容。

正如我在之前的章节中指出的那样，我们认为收入、负债和权益账户通常具有负余额。这听起来可能很奇怪；毕竟，没有人会把他们的总薪水看作是一个负数，当然你的信用卡账单或抵押贷款报表也会报告正数。这是因为在我们的复式记账系统中，我们认为所有账户都从持有人的角度进行持有。我们使用与此角度一致的符号，因为它使得对帐户内容进行所有操作变得简单：它们只是简单地加法，并且所有帐户都被同等对待。

相比之下，会计师传统上将其账户的所有余额保持为正数，并根据应用于哪种类型的账户而以不同方式处理对这些账户的过帐。要应用于每个账户的符号完全由其类型决定：资产和费用账户是借方(debit)账户，而负债、权益和收入账户是贷方 （Credit） 账户并需要进行符号调整。此外，在一个帐户上记账正金额称为“借记【译者注：可以理解为扣款】”，从一个帐户中删除则称为“贷记【译者注：可以理解为入账】”。例如，请参阅[此外部文档](https://www.accountingtools.com/articles/debits-and-credits)，几乎让我头痛欲裂，而这个[最近的主题](https://groups.google.com/g/beancount/c/S_Ac6sbetWg/m/Ec-QeB8CBAAJ)有更多细节。这种处理过程使一切变得比必须复杂得多。

这种方法的问题在于，对交易中各个记账金额进行求和不再是一个简单的加法。例如，假设你正在创建一笔新交易，并向两个资产账户、一个支出账户和一个收入账户记帐，系统告诉你有 9.95 美元的差错。你盯着记录看了半天；哪个记账太小了？还是其中一个记账太大了？此外，也许需要添加新的记账，但它应该记到借方账户还是贷方账户呢？这需要进行繁琐的心理运算。一些双重会计软件试图通过为借方和贷方分别创建列，并允许用户仅在与每个记帐类型相对应的列中输入金额来处理此类问题。这可以在视觉上提供帮助，但为什么不直接使用符号呢？

此外，当你查看会计公式时，还必须考虑它们的符号。这使得对它们进行转换变得很麻烦，并将本质上是对记账进行简单求和的操作变成了一个复杂混乱、难以理解的过程。

在纯文本会计中，我们宁愿摆脱这种不方便的负数。我们只使用加法，并学会记住负债、权益和收入账户通常具有负余额。虽然这很不寻常，但更容易理解。如果需要查看仅包含正数的传统报告，则可以在报告代码中触发该操作[^4]，反转符号以将其呈现在输出中。

# 会计恒等式

根据前面的部分，我们可以轻松地用有符号的术语表达会计方程。如果，

- A = 所有资产记账之和
- L = 所有负债记账之和
- X = 所有支出记账之和
- I = 所有收入记账之和
- E = 所有股权记账之和

我们可以这样：

```
A + L + E + X + I = 0
```

这是由于以下事实导致的：

```
sum(all postings) = 0

所有记账的总和 = 0
```

这是因为每笔交易都被 Beancount 强制保证总和为零：

```
for all transactions t, sum(postings of t) = 0

对于所有的交易 t，t 的所有账目之和等于 0
```

此外，收入和支出记账的总和是净收入 （NI）：

```
NI = X + I
```

如果我们通过将收入清算到股权留存收益账户来反映总净收入影响，调整股权，则可以得到更新后的股权价值（E'）：

```
E’ = E + NI = E + X + I
```

我们有一个简化的会计公式：

```
A + L + E' = 0
```

如果我们调整借方和贷方的符号（参见前一节），并且所有金额都是正数，那么这就变成了熟悉的会计恒等式：

```
Assets - Liabilities = Equity
```

正如你所看到的，总是把数字加起来要容易得多。

# 纯文本记账

好的，现在我们理解了这种方法及其在理论上能为我们做些什么。复式记账系统的目的是允许你将发生在各种真实账户中的交易复制到一个单一、统一的系统中，在一个共同的表示下，并从这些数据中提取各种视图和报告。现在让我们把注意力转向如何实践记录这些数据。

本文介绍了 Beancount，其目的是 “使用文本文件进行复式记账”。Beancount 实现了一个解析器，用于解析简单语法以记录交易和记账。例如交易的语法看起来像这样：

```
2016-12-06 * "Biang!" "Dinner"
  Liabilities:CreditCard   -47.23 USD
  Expenses:Restaurants
```

你可以在一个文件中写入许多这样的声明，Beancount 将读取它并在内存中创建相应的数据结构。

**验证 （Verification）**。在解析完交易后，Beancount 还会验证复式记账法则：它检查所有交易的记账总和是否为零。如果你犯了错误并记录了一个非零余额的交易，则会显示错误。

**余额断言 （Balance Assertions）**。Beancount 允许你复制从外部账户声明的余额，例如月度对账单上写的余额。它会处理这些信息并检查输入交易产生的余额是否与声明的余额相匹配。这有助于你轻松地发现和纠正错误。

**插件 （Plugins）**。Beancount 允许你构建可以自动化和/或处理输入文件中的交易流的程序。你可以通过编写直接处理交易流的代码来构建自定义功能。

**查询和报告（Querying & Reporting）**。它提供了工具来处理交易流，以生成我们在本文中早期讨论过的各种报告。

还有一些细节，例如 Beancount 允许你跟踪成本基础和进行货币转换，但这就是它的本质。

# 表格视角

邮件列表上用户几乎总是提出的关于如何计算或跟踪某些值的问题，其实可以很容易地解决：只需将数据视为一长串行，其中一些需要进行过滤和聚合。如果你考虑到我们最终所做的就是推导这些记账的总和，并且交易和记账的属性允许我们过滤记账的子集，那么它总是变得非常简单。在几乎所有情况下，答案都是找到某种方式来消除对记账进行选择时可能存在歧义性，例如通记账户名称、附加标签、使用某些元数据等。考虑将此数据表示为表格可能会有启发作用。

假设你有两个表：一个包含每个交易的字段，例如日期和描述，另一个包含每个记账的字段，例如账户、金额和货币，以及对其父交易的引用。表示数据最简单的方法是连接 （Join）这两个表，在每个记账中复制父交易的值。

比如，这个 Beancount 输入：

```
2016-12-04 * "Christmas gift"
  Liabilities:CreditCard       -153.45 USD
  Expenses:Gifts

2016-12-06 * "Biang!" "Dinner"
  Liabilities:CreditCard   -47.23 USD
  Expenses:Restaurants

2016-12-07 * "Pouring Ribbons" "Drinks with friends"
  Assets:Cash     -25.00 USD
  Expenses:Tips     4.00 USD
  Expenses:Alcohol
```

可以像这样呈现成一个表格：

| Date       | Fl | Payee           | Narration           | Account                | Number  | Ccy |
|------------|----|-----------------|---------------------|------------------------|---------|-----|
| 2016-12-04 | *  |                 | Christmas gift      | Liabilities:CreditCard | -153.45 | USD |
| 2016-12-04 | *  |                 | Christmas gift      | Expenses:Gifts         | 153.45  | USD |
| 2016-12-06 | *  | Biang!          | Dinner              | Liabilities:CreditCard | -47.23  | USD |
| 2016-12-06 | *  | Biang!          | Dinner              | Expenses:Restaurants   | 47.23   | USD |
| 2016-12-07 | *  | Pouring Ribbons | Drinks with friends | Assets:Cash            | -25.00  | USD |
| 2016-12-07 | *  | Pouring Ribbons | Drinks with friends | Expenses:Tips          | 4.00    | USD |
| 2016-12-07 | *  | Pouring Ribbons | Drinks with friends | Expenses:Alcohol       | 21.00   | USD |

请注意，每个记账都会复制交易字段的值。这就像常规数据库连接操作一样。记账字段从 “Account” 列开始。（还要注意，此示例表格是简化的；实际上有更多的字段。）

如果你有一个像这样的连接表，你可以对其进行过滤并汇总任意分组的记账金额。这正是 bean-query 工具允许你执行的操作：你可以在数据上运行与内存表等效的 SQL 查询，并列出如下值：

```mysql
SELECT date, payee, number
WHERE account = "Liabilities:CreditCard";
```

或者像这样聚合持仓：

```mysql
SELECT account, sum(position)
GROUP BY account;
```

这个简单的命令会生成试算平衡表。

请注意，表格表示并不会本质上限制记账总和为零。如果你在 WHERE 子句中始终选择每个匹配交易的所有记账，则可以确保所有记账的最终总和为零。否则，总和可能是其他任何值。这是需要记住的一些事情。

如果你熟悉 SQL 数据库，你可能会问为什么 Beancount 不直接处理数据以填充现有的数据库系统，这样用户就可以使用那些数据库工具。这其中有两个主要原因：

- 报告操作。 为了生成收入报表和资产负债表，需要使用先前描述的清除、打开和关闭操作对交易列表进行预处理。这些操作在数据库查询中实现并不容易，并且依赖于报告本身，理想情况下不需要修改输入数据。我们必须将记账数据加载到内存中，然后运行一些代码。通过解析输入文件，我们已经在执行此操作；数据库步骤是多余的。

- 聚和持仓。 虽然在本文档中我们还没有讨论过，但账户的内容可能包含不同类型的商品以及附带成本基础的持仓。这些持仓如何聚合在一起需要实现自定义数据类型，因为它遵循有关持仓如何相互抵消的某些规则（详见[《库存工作原理》](https://beancount.github.io/docs/how_inventories_work.html)）。如果要超出仅使用单个货币并忽略成本基础的情况下，在 SQL 数据库中构建这些操作将非常困难。

这就是为什么 Beancount 提供了一个自定义工具来直接处理和查询其数据的原因：它提供了自己的 SQL 客户端实现，让你可以指定开放和关闭日期，并利用自定义“库存”数据结构创建记账持仓总数。该工具支持 Beancount 核心类型的列：Amount (金额)、Position (持仓) 和 Inventory (仓库) 对象。

（无论如何，如果你还不信服，Beancount 提供了一种将其内容导出到常规 SQL 数据库系统的[工具](https://github.com/beancount/beancount/tree/v2/bin/bean-sql)。如果你愿意，请随意尝试并自行实验。）

[^1]: 请不要关注这些大数字中的数字，它们是随机生成的，不反映实际情况。我们只对这些图表的结构感兴趣。

[^2]: 请注意，这与“清算交易”一词无关，后者意味着承认或标记某些交易已经被簿记员查看并检查其正确性。

[^3]: 请注意，操作与 Beancount 提供的 Open 和 Close 指令无关。

[^4]: 目前在 Beancount 中还没有提供此功能，但实现起来非常简单。我们只需要倒转负债、收入和权益账户余额即可。最终将提供此功能。