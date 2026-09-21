import SwiftUI

/// Listening (reciter, repeat), memorisation options and offline storage.
struct ToolsSheet: View {
    let page: Int
    let selectedAyah: Int?
    @Binding var reciterId: String
    @Binding var repeatCount: Int
    @Binding var autoAdvance: Bool
    @Binding var hideMode: Bool
    @Binding var progressAyah: Int
    @Binding var keepMarkers: Bool
    @Binding var hideWords: Bool
    @Binding var keepOpening: Bool
    let onHideAll: () -> Void
    let onGoTo: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var confirmDelete = false
    @State private var joinCode = ""
    private var sync: SyncService { SyncService.shared }

    private let quran = Quran.shared
    private var player: AyahPlayer { AyahPlayer.shared }
    private var images: PageImageStore { PageImageStore.shared }
    private var reciter: Reciter { Reciters.byId(reciterId) }

    var body: some View {
        NavigationStack {
            Form {
                progress
                listening
                memorising
                syncing
                offline
            }
            #if os(macOS)
            .formStyle(.grouped)
            #endif
            .navigationTitle("الأدوات")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        #if os(macOS)
        .frame(minWidth: 440, minHeight: 600)
        #endif
    }

    private var progress: some View {
        Section("موضعي") {
            if progressAyah > 0 {
                let a = quran.ayah(progressAyah)
                LabeledContent("آخر ما بلغت",
                               value: "\(quran.label(ayahId: progressAyah)) · صفحة \(Quran.arabicDigits(a.pageStart))")
                Button("اذهب إلى موضعي") { onGoTo(a.pageStart) }
            } else {
                Text("لم تحفظ موضعًا بعد. المسْ آية في وضع القراءة ثم اضغط «احفظ».")
                    .foregroundStyle(.secondary)
            }
            if let id = selectedAyah, id != progressAyah {
                Button("احفظ الآية المحددة كموضعي: \(quran.label(ayahId: id))") { progressAyah = id }
            }
            if progressAyah > 0 {
                Button("مسح الموضع", role: .destructive) { progressAyah = 0 }
            }
        }
    }

    private var syncing: some View {
        Section("المزامنة بين الأجهزة") {
            if sync.isOn {
                LabeledContent("رمز المزامنة") {
                    Text(sync.displayCode)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .environment(\.layoutDirection, .leftToRight)
                }
                Button("نسخ الرمز") { Self.copy(sync.displayCode) }
                Button(sync.status == .syncing ? "جارٍ المزامنة…" : "زامِن الآن") {
                    Task { await sync.syncNow() }
                }
                .disabled(sync.status == .syncing)
                if let last = sync.lastSync {
                    LabeledContent("آخر مزامنة") { Text(last, style: .relative) }
                }
                Button("إيقاف المزامنة على هذا الجهاز", role: .destructive) { sync.disconnect() }
            } else {
                Button("إنشاء رمز مزامنة") { Task { await sync.create() } }
                    .disabled(sync.status == .syncing)
                HStack {
                    TextField("رمز من جهاز آخر", text: $joinCode)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.characters)
                        #endif
                        .font(.system(.body, design: .monospaced))
                        .environment(\.layoutDirection, .leftToRight)
                        .onSubmit { Task { await sync.join(joinCode) } }
                    Button("ربط") { Task { await sync.join(joinCode) } }
                        .disabled(joinCode.filter { $0.isLetter || $0.isNumber }.count != 10
                                  || sync.status == .syncing)
                }
            }
            if case .failed(let message) = sync.status {
                Text(message).foregroundStyle(.red).font(.footnote)
            }
            Text(sync.isOn
                 ? "أدخل هذا الرمز في الجهاز الآخر. تتزامن الصفحة والموضع والإعدادات؛ أمّا الصفحات المحفوظة فتبقى على كل جهاز."
                 : "أنشئ رمزًا على أحد الجهازين ثم أدخله في الآخر. لا حساب ولا تسجيل دخول.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private static func copy(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }

    private var listening: some View {
        Section("الاستماع") {
            Picker("القارئ", selection: $reciterId) {
                ForEach(Reciters.all) { r in
                    Text(r.nameAr + (r.timed ? "" : " (سورة كاملة)")).tag(r.id)
                }
            }
            Picker("تكرار", selection: $repeatCount) {
                ForEach([1, 3, 5, 10], id: \.self) { n in
                    Text("\(Quran.arabicDigits(n))×").tag(n)
                }
            }
            if player.isBusy {
                Button("إيقاف", role: .destructive) { player.stop() }
                if player.status == .loading {
                    Text("جارٍ التحميل…").foregroundStyle(.secondary)
                } else if let id = player.activeAyah {
                    Text("الآن: \(quran.label(ayahId: id))").foregroundStyle(.secondary)
                }
                if let r = player.repeatInfo, r.total > 1 {
                    Text("التكرار \(Quran.arabicDigits(r.current)) / \(Quran.arabicDigits(r.total))")
                        .foregroundStyle(.secondary)
                }
            } else {
                Button("استمع للصفحة") {
                    let info = quran.page(page)
                    player.play(from: info.firstAyahId, to: info.lastAyahId, times: repeatCount, reciter: reciter)
                }
                if let id = selectedAyah {
                    Button("استمع للآية: \(quran.label(ayahId: id))") {
                        player.play(from: id, to: id, times: repeatCount, reciter: reciter)
                    }
                }
            }
            if let e = player.error {
                Text(e).foregroundStyle(.red).font(.footnote)
            }
            Text("تُشغَّل التلاوة من ملفات السور عند MP3Quran؛ وتستمر مع قفل الشاشة.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var memorising: some View {
        Section("الحفظ") {
            Toggle("وضع الإخفاء", isOn: $hideMode)
            Picker("ما يُخفى", selection: $hideWords) {
                Text("آية آية").tag(false)
                Text("كلمة كلمة").tag(true)
            }
            .pickerStyle(.segmented)
            if hideWords {
                Toggle("إبقاء أول كل آية ظاهرًا", isOn: $keepOpening)
            }
            Toggle("إبقاء أرقام الآيات ظاهرة عند الإخفاء", isOn: $keepMarkers)
            Toggle("الانتقال للصفحة التالية تلقائيًا بعد إظهار آخر الصفحة", isOn: $autoAdvance)
            if hideMode {
                Button("أخفِ الكل") { onHideAll() }
            }
            Text(hideWords
                 ? "في وضع الإخفاء المسْ الكلمة لإظهارها، أو اضغط «التالي» لإظهار الكلمات بالترتيب. أول كل آية يبقى ظاهرًا لتتذكّر منه بقيّتها."
                 : "في وضع الإخفاء المسْ الآية لإظهارها، أو اضغط «التالي» لإظهار الآيات بالترتيب.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var offline: some View {
        let juz = quran.page(page).juz
        let range = quran.juzPageRange(juz)
        let juzDone = images.downloadedCount(in: range)
        let juzComplete = juzDone == range.count
        let allDone = images.downloaded.count
        let allComplete = allDone >= quran.pageCount
        let size = ByteCountFormatter.string(fromByteCount: images.storedBytes(), countStyle: .file)
        return Section("دون اتصال") {
            LabeledContent("الجزء \(Quran.arabicDigits(juz))",
                           value: juzComplete
                               ? "محفوظ ✓"
                               : "\(Quran.arabicDigits(juzDone)) / \(Quran.arabicDigits(range.count)) صفحة")
            LabeledContent("المصحف كاملًا",
                           value: allComplete
                               ? "محفوظ كاملًا ✓ · \(size)"
                               : "\(Quran.arabicDigits(allDone)) / \(Quran.arabicDigits(quran.pageCount)) صفحة · \(size)")
            if images.downloading, let p = images.downloadProgress {
                ProgressView(value: Double(p.done), total: Double(max(1, p.total))) {
                    Text("جارٍ التنزيل \(Quran.arabicDigits(p.done)) / \(Quran.arabicDigits(p.total))")
                }
                Button("إيقاف التنزيل", role: .destructive) { images.cancelDownload() }
            } else {
                if !juzComplete {
                    Button("حفظ الجزء \(Quran.arabicDigits(juz)) دون اتصال") {
                        images.downloadForOffline(Array(range))
                    }
                }
                if !allComplete {
                    Button("حفظ المصحف كاملًا") {
                        images.downloadForOffline(Array(1...quran.pageCount))
                    }
                }
                if allDone > 0 {
                    Button("حذف الصفحات المحفوظة", role: .destructive) { confirmDelete = true }
                        .confirmationDialog("حذف الصفحات المحفوظة؟", isPresented: $confirmDelete,
                                            titleVisibility: .visible) {
                            Button("حذف \(size)", role: .destructive) { images.removeAllStored() }
                        } message: {
                            Text("ستُحمَّل الصفحات من جديد عند فتحها.")
                        }
                }
            }
            Text(allComplete
                 ? "كل الصفحات محفوظة على الجهاز؛ يعمل المصحف دون اتصال بالكامل."
                 : "كل صفحة تفتحها تُحفظ على الجهاز تلقائيًا ولا تُحذف؛ الحفظ المسبق يفيد عند السفر.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
