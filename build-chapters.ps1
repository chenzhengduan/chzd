$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$baseUrl = 'https://waylandz.com/ai-agent-book'
$outDir = 'D:\czd\chzd\ai-agent-book'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Chapter definitions: slug, title, part (sidebar group)
$chapters = @(
  @{slug='前言'; title='前言'; part='前言'}
  @{slug='Part1概述'; title='Part 1 概述'; part='Part 1 - Agent 基础'}
  @{slug='第01章-Agent的本质'; title='第 1 章：Agent 的本质'; part='Part 1 - Agent 基础'}
  @{slug='第02章-ReAct循环'; title='第 2 章：ReAct 循环'; part='Part 1 - Agent 基础'}
  @{slug='Part2概述'; title='Part 2 概述'; part='Part 2 - 工具与扩展'}
  @{slug='第03章-工具调用基础'; title='第 3 章：工具调用基础'; part='Part 2 - 工具与扩展'}
  @{slug='第04章-MCP协议详解'; title='第 4 章：MCP 协议详解'; part='Part 2 - 工具与扩展'}
  @{slug='第05章-Skills技能系统'; title='第 5 章：Skills 技能系统'; part='Part 2 - 工具与扩展'}
  @{slug='第06章-Hooks与事件系统'; title='第 6 章：Hooks 与事件系统'; part='Part 2 - 工具与扩展'}
  @{slug='Part3概述'; title='Part 3 概述'; part='Part 3 - 上下文与记忆'}
  @{slug='第07章-上下文工程'; title='第 7 章：上下文工程'; part='Part 3 - 上下文与记忆'}
  @{slug='第08章-记忆架构'; title='第 8 章：记忆架构'; part='Part 3 - 上下文与记忆'}
  @{slug='第09章-多轮对话设计'; title='第 9 章：多轮对话设计'; part='Part 3 - 上下文与记忆'}
  @{slug='Part4概述'; title='Part 4 概述'; part='Part 4 - 单 Agent 模式'}
  @{slug='第10章-Planning模式'; title='第 10 章：Planning 模式'; part='Part 4 - 单 Agent 模式'}
  @{slug='第11章-Reflection模式'; title='第 11 章：Reflection 模式'; part='Part 4 - 单 Agent 模式'}
  @{slug='第12章-Chain-of-Thought'; title='第 12 章：Chain-of-Thought'; part='Part 4 - 单 Agent 模式'}
  @{slug='Part5概述'; title='Part 5 概述'; part='Part 5 - 多 Agent 编排'}
  @{slug='第13章-编排基础'; title='第 13 章：编排基础'; part='Part 5 - 多 Agent 编排'}
  @{slug='第14章-DAG工作流'; title='第 14 章：DAG 工作流'; part='Part 5 - 多 Agent 编排'}
  @{slug='第15章-Swarm模式'; title='第 15 章：Swarm 模式'; part='Part 5 - 多 Agent 编排'}
  @{slug='第16章-Handoff机制'; title='第 16 章：Handoff 机制'; part='Part 5 - 多 Agent 编排'}
  @{slug='Part6概述'; title='Part 6 概述'; part='Part 6 - 高级推理'}
  @{slug='第17章-Tree-of-Thoughts'; title='第 17 章：Tree-of-Thoughts'; part='Part 6 - 高级推理'}
  @{slug='第18章-Debate模式'; title='第 18 章：Debate 模式'; part='Part 6 - 高级推理'}
  @{slug='第19章-Research-Synthesis'; title='第 19 章：Research-Synthesis'; part='Part 6 - 高级推理'}
  @{slug='Part7概述'; title='Part 7 概述'; part='Part 7 - 生产架构'}
  @{slug='第20章-三层架构设计'; title='第 20 章：三层架构设计'; part='Part 7 - 生产架构'}
  @{slug='第21章-Temporal工作流'; title='第 21 章：Temporal 工作流'; part='Part 7 - 生产架构'}
  @{slug='第22章-可观测性'; title='第 22 章：可观测性'; part='Part 7 - 生产架构'}
  @{slug='Part8概述'; title='Part 8 概述'; part='Part 8 - 企业级特性'}
  @{slug='第23章-Token预算控制'; title='第 23 章：Token 预算控制'; part='Part 8 - 企业级特性'}
  @{slug='第24章-策略治理'; title='第 24 章：策略治理'; part='Part 8 - 企业级特性'}
  @{slug='第25章-安全执行'; title='第 25 章：安全执行'; part='Part 8 - 企业级特性'}
  @{slug='第26章-多租户设计'; title='第 26 章：多租户设计'; part='Part 8 - 企业级特性'}
  @{slug='Part9概述'; title='Part 9 概述'; part='Part 9 - 前沿实践'}
  @{slug='第27章-Deep-Research'; title='第 27 章：Deep Research'; part='Part 9 - 前沿实践'}
  @{slug='第28章-Computer-Use'; title='第 28 章：Computer Use'; part='Part 9 - 前沿实践'}
  @{slug='第29章-Agentic-Coding'; title='第 29 章：Agentic Coding'; part='Part 9 - 前沿实践'}
  @{slug='第30章-Background-Agents'; title='第 30 章：Background Agents'; part='Part 9 - 前沿实践'}
  @{slug='第31章-分层模型策略'; title='第 31 章：分层模型策略'; part='Part 9 - 前沿实践'}
  @{slug='第32章-OpenClaw时代'; title='第 32 章：OpenClaw 时代'; part='Part 9 - 前沿实践'}
  @{slug='第33章-Building-on-the-Harness-ShanClaw'; title='第 33 章：Building on the Harness - Kocoro'; part='Part 9 - 前沿实践'}
  @{slug='Part10-Agent-Loop工程'; title='Part 10 概述'; part='Part 10 - Agent Loop 工程'}
  @{slug='第34章-从DAG到Agent-Loop'; title='第 34 章：从 DAG 到 Agent Loop'; part='Part 10 - Agent Loop 工程'}
  @{slug='第35章-上下文压缩'; title='第 35 章：上下文压缩'; part='Part 10 - Agent Loop 工程'}
  @{slug='第36章-Tool-Result预算与外溢'; title='第 36 章：Tool Result 预算与外溢'; part='Part 10 - Agent Loop 工程'}
  @{slug='第37章-分层压缩'; title='第 37 章：分层压缩'; part='Part 10 - Agent Loop 工程'}
  @{slug='第38章-Deferred-Tool-Loading与Tool-Search'; title='第 38 章：Deferred Tool Loading 与 Tool Search'; part='Part 10 - Agent Loop 工程'}
  @{slug='第39章-Prompt-Cache稳定性'; title='第 39 章：Prompt Cache 稳定性'; part='Part 10 - Agent Loop 工程'}
  @{slug='第40章-持久化Agent-Loop'; title='第 40 章：持久化 Agent Loop'; part='Part 10 - Agent Loop 工程'}
  @{slug='第41章-运行中操控Agent'; title='第 41 章：运行中操控 Agent'; part='Part 10 - Agent Loop 工程'}
  @{slug='第42章-Agent超时与Watchdog'; title='第 42 章：Agent 超时与 Watchdog'; part='Part 10 - Agent Loop 工程'}
  @{slug='第43章-卡循环检测'; title='第 43 章：卡循环检测'; part='Part 10 - Agent Loop 工程'}
  @{slug='第44章-并行工具执行'; title='第 44 章：并行工具执行'; part='Part 10 - Agent Loop 工程'}
  @{slug='第45章-Computer-Use上下文管理'; title='第 45 章：Computer Use 上下文管理'; part='Part 10 - Agent Loop 工程'}
  @{slug='Part10概述'; title='附录概述'; part='附录'}
  @{slug='附录A-术语表'; title='附录 A：术语表'; part='附录'}
  @{slug='附录B-模式选择指南'; title='附录 B：模式选择指南'; part='附录'}
  @{slug='附录C-常见问题FAQ'; title='附录 C：常见问题 FAQ'; part='附录'}
)

function Download-Page($slug) {
  $url = if($slug) { "$baseUrl/$slug/" } else { "$baseUrl/" }
  $wc = New-Object System.Net.WebClient
  $wc.Headers.Add('User-Agent','Mozilla/5.0 (Windows NT 10.0; Win64; x64)')
  $wc.Headers.Add('Accept-Encoding','gzip')
  $bytes = $wc.DownloadData($url)
  $ms = New-Object System.IO.MemoryStream(,$bytes)
  $gz = New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
  $reader = New-Object System.IO.StreamReader($gz, [System.Text.Encoding]::UTF8)
  $html = $reader.ReadToEnd()
  $reader.Close()
  $gz.Close()
  $ms.Close()
  return $html
}

function Extract-Article($html) {
  $marker = '<article class="prose">'
  $idx = $html.IndexOf($marker)
  if($idx -lt 0) { $marker = '<article'; $idx = $html.IndexOf($marker) }
  if($idx -lt 0) { return $null }
  $endIdx = $html.IndexOf('</article>', $idx)
  if($endIdx -lt 0) { return $null }
  return $html.Substring($idx, $endIdx - $idx + 10)
}

function Extract-Title($html) {
  $s = $html.IndexOf('<title>')
  $e = $html.IndexOf('</title>', $s)
  if($s -lt 0 -or $e -lt 0) { return 'AI Agent 架构模式与实战' }
  $title = $html.Substring($s + 7, $e - $s - 7)
  $title = $title -replace ' \| Wayland Zhang$', ''
  $title = $title -replace ' Wayland Zhang$', ''
  return $title.Trim()
}

function Process-Content($content) {
  if(-not $content) { return '<article class="prose dark:prose-invert fade-in"><p>内容加载失败</p></article>' }
  $content = $content -replace 'Wayland Zhang', 'chad'
  $content = $content -replace '@waylandzhang', '@chad'
  $content = $content -replace '<article class="prose">', '<article class="prose dark:prose-invert fade-in">'
  $content = $content -replace 'href="/ai-agent-book/([^"]+)/"', 'href="$1.html"'
  $content = $content -replace 'src="/book-images/', 'src="https://waylandz.com/book-images/'
  $content = $content -replace 'src="/social-photo', 'src="https://waylandz.com/social-photo'
  $content = $content -replace 'href="https://waylandz\.com"', 'href="#"'
  $content = $content -replace 'href="https://waylandz\.com/"', 'href="#"'
  $content = $content -replace 'href="https://github\.com/Kocoro-lab/ai-agent-book"', 'href="#"'
  $content = $content -replace 'href="https://shannon\.run"', 'href="#"'
  $content = $content -replace 'href="https://kocoro\.ai"', 'href="#"'
  $content = $content -replace 'data-precedence="[^"]*"', ''
  $content = $content -replace 'data-next-script=', 'data-disabled='
  $content = $content -replace 'data-next-style=', 'data-disabled='
  return $content
}

function Get-SidebarHtml($activeSlug, $chapters) {
  $sb = New-Object System.Text.StringBuilder
  $currentPart = ''
  foreach($ch in $chapters) {
    if($ch.part -ne $currentPart) {
      if($currentPart -ne '') { [void]$sb.Append('</ul></div>') }
      $currentPart = $ch.part
      [void]$sb.Append('<div class="sidebar-section"><div class="section-title">')
      [void]$sb.Append($currentPart)
      [void]$sb.Append('</div><ul class="chapter-list">')
    }
    $activeClass = if($ch.slug -eq $activeSlug) { ' active' } else { '' }
    [void]$sb.Append('<li><a class="chapter-link')
    [void]$sb.Append($activeClass)
    [void]$sb.Append('" href="')
    [void]$sb.Append($ch.slug)
    [void]$sb.Append('.html">')
    [void]$sb.Append($ch.title)
    [void]$sb.Append('</a></li>')
  }
  if($currentPart -ne '') { [void]$sb.Append('</ul></div>') }
  return $sb.ToString()
}

function Get-PageHtml($title, $articleHtml, $sidebarHtml, $prevCh, $nextCh) {
  $navHtml = ''
  if($prevCh -or $nextCh) {
    $navHtml = '<div class="chapter-nav">'
    if($prevCh) {
      $navHtml += '<a href="' + $prevCh.slug + '.html"><span class="nav-label">上一章</span>' + $prevCh.title + '</a>'
    }
    if($nextCh) {
      $navHtml += '<a href="' + $nextCh.slug + '.html" class="nav-next"><span class="nav-label">下一章</span>' + $nextCh.title + '</a>'
    }
    $navHtml += '</div>'
  }

  $head = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>$title | chad</title>
<meta name="author" content="chad"/>
<meta name="description" content="AI Agent 架构模式与实战 - chad"/>
<script>(function(){try{var m=window.matchMedia('(prefers-color-scheme:dark)');var apply=function(){var t=localStorage.getItem('theme');document.documentElement.classList.toggle('dark',t==='dark'||(!t&&m.matches))};apply();m.addEventListener('change',apply)}catch(e){}})()</script>
<script src="https://cdn.tailwindcss.com?plugins=typography"></script>
<script>tailwind.config={darkMode:"class",theme:{extend:{typography:{DEFAULT:{css:{maxWidth:"none"}}}}}}</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="style.css"/>
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>📖</text></svg>"/>
</head>
"@

  $bodyPart1 = @"
<body>
<div class="book-layout">
  <header class="book-header">
    <div class="header-content">
      <div class="header-left">
        <button class="mobile-menu-toggle" id="menuToggle" aria-label="Open menu">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="20" height="20"><path stroke-linecap="round" stroke-linejoin="round" d="M3 12h18M3 6h18M3 18h18"></path></svg>
        </button>
        <nav class="header-nav">
          <a class="nav-item" href="index.html">Home</a>
          <a class="nav-item" href="#">Blog</a>
          <span class="nav-item">Books</span>
          <a class="nav-item active hide-mobile" href="index.html">AI Agent 架构模式与实战</a>
        </nav>
      </div>
      <div class="right-controls">
        <span><a class="lang-link active" href="#">中文</a></span>
        <button class="theme-toggle" id="themeToggle" aria-label="Toggle theme">
          <svg class="w-[18px] h-[18px] hidden dark:block" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="4"></circle><path stroke-linecap="round" d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"></path></svg>
          <svg class="w-[18px] h-[18px] block dark:hidden" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z"></path></svg>
        </button>
      </div>
    </div>
  </header>
  <div class="sidebar-overlay" id="sidebarOverlay"></div>
  <div class="book-body">
    <nav class="book-sidebar" id="bookSidebar">
      <button class="sidebar-close" id="sidebarClose" aria-label="Close menu">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="20" height="20"><path stroke-linecap="round" d="M18 6L6 18M6 6l12 12"></path></svg>
      </button>
      <div class="sidebar-header">
        <a class="book-title" href="index.html">AI Agent 架构：从单体到企业级多智能体</a>
      </div>
      <div class="sidebar-content">
"@

  $bodyPart2 = @"
      </div>
    </nav>
    <main class="book-main">
      <div class="book-content">
"@

  $bodyPart3 = @"
        $navHtml
      </div>
    </main>
  </div>
</div>
<script src="script.js"></script>
</body>
</html>
"@

  return $head + "`n" + $bodyPart1 + "`n" + $sidebarHtml + "`n" + $bodyPart2 + "`n" + $articleHtml + "`n" + $bodyPart3
}

# ---- Main ----
Write-Host "=== Building AI Agent Book (author: chad) ==="
Write-Host "Output: $outDir"
Write-Host "Chapters: $($chapters.Count)"
Write-Host ""

# Build overview page (index.html)
Write-Host "[0/59] Downloading overview page..."
try {
  $html = Download-Page ''
  $article = Extract-Article $html
  $title = Extract-Title $html
  $processed = Process-Content $article
  $sidebar = Get-SidebarHtml '' $chapters
  $pageHtml = Get-PageHtml $title $processed $sidebar $null $chapters[0]
  $outPath = Join-Path $outDir 'index.html'
  [System.IO.File]::WriteAllText($outPath, $pageHtml, $utf8NoBom)
  Write-Host "  -> index.html ($($processed.Length) chars)"
} catch {
  Write-Host "  ERROR: $($_.Exception.Message)"
}

# Build chapter pages
$success = 0
$failed = 0
for($i = 0; $i -lt $chapters.Count; $i++) {
  $ch = $chapters[$i]
  $num = $i + 1
  Write-Host "[$num/$($chapters.Count)] $($ch.title)..."
  try {
    $html = Download-Page $ch.slug
    $article = Extract-Article $html
    if(-not $article) {
      Write-Host "  WARNING: No article found, skipping"
      $failed++
      continue
    }
    $title = Extract-Title $html
    $processed = Process-Content $article
    $sidebar = Get-SidebarHtml $ch.slug $chapters
    $prevCh = if($i -gt 0) { $chapters[$i-1] } else { $null }
    $nextCh = if($i -lt $chapters.Count - 1) { $chapters[$i+1] } else { $null }
    $pageHtml = Get-PageHtml $title $processed $sidebar $prevCh $nextCh
    $outPath = Join-Path $outDir ($ch.slug + '.html')
    [System.IO.File]::WriteAllText($outPath, $pageHtml, $utf8NoBom)
    Write-Host "  -> $($ch.slug).html ($($processed.Length) chars)"
    $success++
  } catch {
    Write-Host "  ERROR: $($_.Exception.Message)"
    $failed++
  }
  Start-Sleep -Milliseconds 300
}

Write-Host ""
Write-Host "=== Done ==="
Write-Host "Success: $success / $($chapters.Count)"
Write-Host "Failed: $failed"
