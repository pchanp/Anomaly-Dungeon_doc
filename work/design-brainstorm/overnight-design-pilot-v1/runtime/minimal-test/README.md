# 候補生成なしの最小テスト

Status: Draft。候補生成数0。

初回safe-yoloでネイティブRead/Writeは許可待ちなしで成功。fixtureのREAD_CHECKをoutput/probe.txtへ保存。

停止成功。初回handoff環境変数を子プロセスから外した標準happier resumeで同じHappier IDおよびOpenCode IDが再開し、前の値をファイル再読なしで記憶していた。しかしWriteは許可待ちとなりresumed.txtは未作成。sendのpermission overrideとset-permission-modeだけでは今回の待機を解消できなかった。

追加のhappier opencode --existing-session --resume --permission-mode safe-yoloはmissing session attach secretで失敗。標準resume内部が作るattach情報を持たないため、このコマンドだけを運用手順にしない。

最終状態active=false確認。監視プロセス終了。正本MD、共通パック、ゲーム実装は変更していない。OSの書き込み隔離は未検証。

次の対応はHappierの標準resumeが起動するrunnerへのpermission適用経路の調査・修正。インストール済みCLIの直接改変は今回実施していない。
