# ROLE=B — アイテム

common.mdとセットで使用。Bの予約ID001〜015とBフォルダだけを担当する。

主対象マップは使用文脈。限定入手／使用を確定する意味ではない。保持するか使うか、誰へ渡すか、どこで使うかの判断を作る。単なる鍵や数値上昇品の水増しを避ける。

通常探索品、汎用スキルレアルート品、スロットレアルート品、アノマリー固有交換品を区別する。判断010〜012とeconomy-and-progression.mdを読み、Robux経路を採用済みにしない。研究所のQuest装置を別アイテムへ置換しない。

role_details.routesにAcquire / Hold / Use / Present / Place / Lose / SecureSlot / Sell / Quest / AnomalyInteractionの10経路を各1件記す。関連する経路はProposed、未決はUndecided、無関係はNotApplicableと理由を書く。

出現率／同時出現数を変える案はownership_stateとserver_run_stateを分け、effectsのWorldChangeはRun終了で破棄する契約を参照する。正式Inventory/ItemStackの実装状況をデバッグ境界と混同しない。

未完成A/Cへの接続は予約ID＋必要な性質＋unresolved_refs。相手のNPC、ギミック、スキルを自分で作らない。
