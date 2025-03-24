<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 쪽지함 > null > 쪽지쓰기
-- 작성자 : 이종술
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGridTop;
		var auiGridBottom;
		// 선택된 TAB ID
		var tab_id = 'inner1';
		// 첨부파일의 index 변수
		var fileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var fileCount = 3;
		// 답장/전달 여부
		var isReply = false;
		var caretPos;

		$(document).ready(function () {

			createAUIGridTop();
			createAUIGridBottom();
			$('ul.tabs-c li a').click(function() {
				tab_id = $(this).attr('data-tab');

				$('ul.tabs-c li a').removeClass('active');
				$('.tabs-inner').removeClass('active');

				$(this).addClass('active');
				$("#"+tab_id).addClass('active');
			});

			$('.specialchar button').click(function(){
				setPaperContents($(this).html());
				fnLayerPopup();
			});

			//답장 or 전달일 경우 세팅
			// R : 답장, F : 전달, N : 대상지정 새쪽지
			// 전달에서 온 경우 답장과 다르게 수신자가 없도록 수정 - 211015 이강원
			if('${inputParam.cmd}' == 'R' || '${inputParam.cmd}' == 'N'){
				isReply = '${inputParam.cmd}' == 'N' ? false : true;
				// 실제로 #grid_wrap에 그리드 생성
				var data = {
					'org_name' : '${result.send_org_name}',
					'name' : '${result.send_name}',
					'mem_no' : '${result.send_mem_no}',
					'cmd' : 'TO'
				}
				AUIGrid.addRow(auiGridTop, data, '');
			}

			// 한번에 특수문자 두 개씩 입력되는 현상 FIX - 김경빈
			// fnSetSpecialChar();		//특수문자 입력 설정

			var receiverSize = Number($M.getValue("receiver_mem_list_size")); // 수신자
			var referSize = Number($M.getValue("refer_mem_list_size"));  // 참조자
			var sumVal = receiverSize + referSize;  // 수신자 + 참조자

			// 답장 or 전달일경우 or 수신자, 참조자가 2명이상일 경우 단체회신 여부 confirm
			// 전달인 경우는 해당하지 않도록 수정 - 211015 이강원
			if('${inputParam.cmd}' == 'R') {
				if (sumVal > 1) {
					if (confirm("단체회신을 하려면 확인을\n보낸사람에게만 답장을 쓰려면 취소를\n선택하십시오.") == false) {
						$("#toCnt").text(AUIGrid.getRowCount(auiGridTop));
						return false;
					}
				}
			}

			 // 수신자 목록
			 // 전달일 경우 수신사가 없도록 수정 - 211015 이강원
			var receiverMemList = ${receiver_mem_list};
			if (receiverMemList.length != 0 && '${inputParam.cmd}' != 'F') {
				AUIGrid.setGridData(auiGridTop, receiverMemList);
			}

			// 참조자 목록
			var referMemList = ${refer_mem_list};
			if (referMemList.length != 0 && '${inputParam.cmd}' != 'F') {
				AUIGrid.setGridData(auiGridBottom, referMemList);
			}


			$("#toCnt").text(AUIGrid.getRowCount(auiGridTop));
			$("#ccCnt").text(AUIGrid.getRowCount(auiGridBottom));

			// 엔터 안먹어서 따움표 ' 에서 백틱(키보드 esc 밑에거) ` 으로 수정 - 210528 김상덕
			// https://curryyou.tistory.com/185
			var paperContents = `${inputParam.paper_contents}`.replaceAll("#", "\n");
			$("#paper_contents").text(paperContents);
		});

		// 닫기
		function fnClose() {
			window.close();
		}

		// 개별 대상 조회
		function goSearch() {
			var target = $("input[name=target]:checked").val();

			var itemArr = [];
			itemArr = $("#" + tab_id).find("iframe").get(0).contentWindow.fnSearch($("#search_str").val());
			if(itemArr.length == 0){
				alert("조회되지 않는 사원입니다.");
			}else if(itemArr.length == 1){
				fnAddProc(itemArr);
			}
		}

		// 추가 버튼
		function fnAdd() {
			var itemArr = [];
			itemArr = $("#" + tab_id).find("iframe").get(0).contentWindow.fnData();
			if(itemArr.length == 0){
				alert("대상을 선택해주세요.");
			}else {
				fnAddProc(itemArr);
			}
		}

		// 수신참조 추가
		function fnAddProc(itemArr){
			var target = $("input[name=target]:checked").val();

			if(target == 'To'){

				for (var i = 0; i < itemArr.length; i++) {
					//CC목록에 없고 TO목록에 경우에 없는 경우에만 추가
					if(AUIGrid.isUniqueValue(auiGridTop, "mem_no", itemArr[i].mem_no) && AUIGrid.isUniqueValue(auiGridBottom, "mem_no", itemArr[i].mem_no)){
						if (itemArr[i].mem_no != "") {
							AUIGrid.addRow(auiGridTop, fnAppendJSON(itemArr[i], "cmd", "TO"), "last");
						}
					} else {
						alert("이미 쪽지 수신 대상에 있는 직원입니다.");
						// break; // [17729] 수신 대상에있는 직원만 제외하고 모두 추가하도록 변경 - 김경빈
					}
				}

			}else{

				for (var i = 0; i < itemArr.length; i++) {
					//CC목록에 없고 TO목록에 경우에 없는 경우에만 추가
					if(AUIGrid.isUniqueValue(auiGridTop, "mem_no", itemArr[i].mem_no) && AUIGrid.isUniqueValue(auiGridBottom, "mem_no", itemArr[i].mem_no)){
						if (itemArr[i].mem_no != "") {
							AUIGrid.addRow(auiGridBottom, fnAppendJSON(itemArr[i], "cmd", "CC"), "last");
						}
					} else {
						alert("이미 쪽지 수신 대상에 있는 직원입니다.");
						// break; // [17729] - 김경빈
					}
				}

			}

			$("#toCnt").text(AUIGrid.getRowCount(auiGridTop));
			$("#ccCnt").text(AUIGrid.getRowCount(auiGridBottom));
			$("#search_str").val("");
			$("#search_str").focus();
		}

		//JSON 데이터 추가(배열일경우 모든 ROW에 추가)
		function fnAppendJSON(jsonObj, key, value){
			if(Array.isArray(jsonObj)){
				for(var i = 0 ; i < jsonObj.length ; i++){
					jsonObj[i][key] = value;
				}
			}else{
				jsonObj[key] = value;
			}
			return jsonObj;
		}

		//수신/참조 삭제
		function fnRemove(target) {
			var grid;
			var itemArr = [];

			if(target == 'To'){
				grid = auiGridTop;
			}else{
				grid = auiGridBottom;
			}

			itemArr = AUIGrid.getCheckedRowItemsAll(grid); // 체크된 그리드 데이터

			for(var i = 0 ; i < itemArr.length ; i++){
				AUIGrid.removeRowByRowId(grid, itemArr[i]._$uid);
			}
			AUIGrid.removeSoftRows(grid);

			$('#toCnt').text(AUIGrid.getRowCount(auiGridTop));
			$('#ccCnt').text(AUIGrid.getRowCount(auiGridBottom));
		}

		// 특수문자 입력 팝업
		function fnOpenSpecialCharPopup() {
			if(isReply){
				caretPos = $('#reply_contents').prop("selectionStart");
			}
			else {
				caretPos = $('#paper_contents').prop("selectionStart");
			}

			$M.goNextPageLayerDiv('open_layer_specialChar');
		}

		// 특수문자 넣기
		function fnSetSpecialChar() {
			$('.specialchar button').click(function(v) {
				var text = $(event.target).text();
				if(isReply){
					fnTypeInTextarea($("#reply_contents"),text);
				}
				else{
					fnTypeInTextarea($("#paper_contents"),text);
				}

				return false;
			})
		}

		// 커서에 입력
		function fnTypeInTextarea(el, newText) {
			  var start = el.prop("selectionStart")
			  var end = el.prop("selectionEnd")
			  var text = el.val()
			  var before = text.substring(0, start)
			  var after  = text.substring(end, text.length)
			  el.val(before + newText + after)
			  el[0].selectionStart = el[0].selectionEnd = start + newText.length
			  el.focus()
			  return false
		}


		// 레이어 팝업 닫기
		function fnLayerPopup() {
			$.magnificPopup.close();
		}

		//자주쓰는문구 팝업
		function goFavouriteText() {
			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=500, height=430, left=0, top=0";
			$M.goNextPage('/mmyy/mmyy0102p04/', '', {popupStatus : poppupOption});
		}

		//쪽지전송
		function goMessageSend() {
			var toCnt = AUIGrid.getRowCount(auiGridTop);
			if(toCnt == 0){
				alert("수신자를 1명이상 선택해주세요.");
				return;
			}

			if(!$M.validation(document.main_form)) {
				return;
			};

			var gridTopData = AUIGrid.getGridData(auiGridTop);
			var gridBomData = AUIGrid.getGridData(auiGridBottom);

			for (var i = 0; i < gridBomData.length; i++) {
				var arrlen = gridTopData.length;

				for (var j = 0; j < arrlen; j++) {
					if (gridBomData[i].mem_no == gridTopData[j].mem_no) {
						alert("수신자 또는 참조자 목록에 중복된 직원이 있습니다.\n대상에서 삭제 후 진행 해주세요.");
						return;
					}
				}
			}

			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGridTop, auiGridBottom];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}
			var gridFrm = fnGridDataToForm(concatCols, concatList);
			var paramFrm = $M.toValueForm(document.main_form);
			$(paramFrm).append($(gridFrm).html());

			var idx = 1;
			$('#main_form input[name="file_seq"]').each(function() {
				var str = 'file_seq_' + idx;
				$M.setHiddenValue(paramFrm, str, $(this).val());
				idx++;
			});


// 			if(isReply){
			// Q&A  13014 쪽지 전달시 오류. R답변 or F전달 이면 paper_contents에 세팅. 211019 김상덕
			if("R" == "${inputParam.cmd}"  || "F" == "${inputParam.cmd}"){
				$M.setValue(paramFrm, 'paper_contents', $M.getValue(paramFrm, 'reply_contents'));
			}

			if('${inputParam.cmd}' == 'R'){
				$M.setHiddenValue(paramFrm, 'reply_yn', 'Y');
			}else{
				$M.setHiddenValue(paramFrm, 'reply_yn', 'N');
			}

			var msg = "발송하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/save", paramFrm, {method : 'post'},
				function(result) {
			    	if(result.success) {
			    		fnClose();
					}
				}
			);
		}

		//첨부파일열기
		function goSearchFile(){
			if($("input[name='file_seq']").size() >= fileCount) {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setFileInfo', 'upload_type=NOTICE&file_type=both&max_size=2048');
		}

		//첨부파일 세팅
		function setFileInfo(result) {
			var str = '';
			str += '<div class="table-attfile-item file_' + fileIndex + '">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '</div>';
			$('.file_div').append(str);
			fileIndex++;
		}

		// 첨부파일 삭제
		function fnRemoveFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".file_" + fileIndex).remove();
			} else {
				return false;
			}
		}

		//자주쓰는문구, 특수문자 콜백
		function setPaperContents(str){
			if(isReply){
				fnTypeInTextarea($("#reply_contents"),str);
			}else{
				fnTypeInTextarea($("#paper_contents"),str);
			}
		}

		var columnLayout = [
			{
				headerText : "부서",
				dataField : "org_name",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				},
			},
			{
				headerText : "사원명",
				dataField : "name",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "직원번호",
				dataField : "mem_no",
				visible : false,
			},
			{
				headerText : "수신/참조구분",
				dataField : "cmd",
				visible : false,
			}
		];

		function createAUIGridTop() {
			var gridPros = {
				rowIdField : "_$uid",
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true
			};

			// 실제로 #grid_wrap에 그리드 생성
			auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
		}

		function createAUIGridBottom() {
			var gridPros = {
				rowIdField : "_$uid",
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true
			};

			// 실제로 #grid_wrap에 그리드 생성
			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
		}
	</script>
</head>
<body   class="bg-white" >
<form id="main_form" name="main_form">
	<input type="hidden" id="paper_gubun_cd" name="paper_gubun_cd" value="${result.paper_gubun_cd}" />
	<input type="hidden" id="menu_seq" name="menu_seq" value="${inputParam.menu_seq}" />
	<input type="hidden" id="pop_get_param" name="pop_get_param" value="${pop_get_param}" />
	<input type="hidden" id="s_paper_seq" name="s_paper_seq" value="${inputParam.s_paper_seq}" />
	<input type="hidden" id="receiver_mem_list_size" name="receiver_mem_list_size" value="${receiver_mem_list_size}" />
	<input type="hidden" id="refer_mem_list_size" name="refer_mem_list_size" value="${refer_mem_list_size}" />


	<div class="popup-wrap width-100per">
		<!-- 메인 타이틀 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /메인 타이틀 -->
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
				<div class="row">
					<div class="col-6">
						<!-- 대상자조회 -->
						<div>
							<div class="title-wrap">
								<h4>대상자조회</h4>
							</div>
							<!-- 검색영역 -->
							<div class="search-wrap mt5">
								<table class="table">
									<colgroup>
										<col width="65px">
										<col width="100px">
										<col width="">
									</colgroup>
									<tbody>
									<tr>
										<th>개별대상</th>
										<td>
											<input type="text" id="search_str" class="form-control" onkeyup="if(window.event.keyCode == 13) goSearch();">
										</td>
										<td>
											<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
										</td>
									</tr>
									</tbody>
								</table>
							</div>
							<!-- /검색영역 -->
							<!-- 조직도 탭 -->
							<!-- 탭 -->
							<ul class="tabs-c tabs-justified mt10">
								<li class="tabs-item">
									<a href="#" class="tabs-link font-12 active"  data-tab="inner1">조직도</a>
								</li>
								<li class="tabs-item">
									<a href="#" class="tabs-link font-12"  data-tab="inner2">발송그룹</a>
								</li>
							</ul>
							<div id="inner1" class="tabs-inner active">
								<div class="tabs-inner-line">
									<iframe src="/mmyy/mmyy0102p0101" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 340px;" scrolling="no"></iframe>
								</div>
							</div>
							<div id="inner2" class="tabs-inner">
								<div class="tabs-inner-line">
									<iframe src="/mmyy/mmyy0102p0102" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 340px;" scrolling="no"></iframe>
								</div>
							</div>
							<!-- /탭 -->
							<div class="tabs-inner mr-1">
								<div class="tabs-inner-line">
									<div style="margin-top: 5px; height: 240px; border: 1px solid #ffcc00;">그리드영역</div>
								</div>
							</div>
							<!-- /조직도 탭 -->
						</div>
						<!-- /대상자조회-->
					</div>
					<div class="col btn-switch mt30">
						<div class="btn btn-default" onclick="javascript:fnAdd()"><i class="material-iconsarrow_right text-default"></i></div>
					</div>
					<div class="col" style="width: calc(50% - 60px); margin-top: 74px">
						<!-- 수신자 -->
						<div>
							<div class="title-wrap">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="target" checked="checked" value="To">
									<label class="form-check-label">수신자 (<span id="toCnt">0</span>명)</label>
								</div>
								<button type="button" class="btn btn-default" onclick="javascript:fnRemove('To');"><i class="material-iconsclose text-default"></i>삭제</button>
							</div>
							<div id="auiGridTop" style="margin-top: 5px; height: 164px;"></div>
						</div>
						<!-- /수신자 -->
						<!-- 참조자 -->
						<div>
							<div class="title-wrap mt10">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="target" value="Cc">
									<label class="form-check-label">참조자 (<span id="ccCnt">0</span>명)</label>
								</div>
								<button type="button" class="btn btn-default" onclick="javascript:fnRemove('Cc');"><i class="material-iconsclose text-default"></i>삭제</button>
							</div>
							<div id="auiGridBottom" style="margin-top: 5px; height: 164px;"></div>
						</div>
						<!-- /참조자 -->
					</div>
				</div>
				<!-- 쪽지내용 -->
				<div>
					<div class="title-wrap mt10">
						<div class="left">
							<h4>쪽지내용</h4>
						</div>
						<div class="right">
							<button type="button" class="btn btn-default dpf-inline" onclick="javascript:goFavouriteText()"><i class="icon-btn-favorite"></i> 자주쓰는문구</button>
							<button type="button" class="btn btn-default" onclick="javascript:fnOpenSpecialCharPopup();">특수문자</button>
						</div>
					</div>

					<!-- 폼테이블 -->
					<div>
						<table class="table-border mt5">
							<colgroup>
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<!-- 답장혹은 전달시 원본내용은 보여주지않음 -->
							<c:if test="${inputParam.cmd != 'R' && inputParam.cmd != 'F'}">
							<tr>
								<th class="text-right">내용</th>
								<td>
									<textarea id="paper_contents" name="paper_contents" class="form-control" required="required" alt="내용" style="height: 250px; overflow-y:scroll;" ${inputParam.cmd == 'R' || inputParam.cmd == 'F' ? 'disabled' : ''}>${result.paper_contents}</textarea>
								</td>
							</tr>
							</c:if>
							<c:if test="${inputParam.cmd == 'R' || inputParam.cmd == 'F'}">
							<tr>
								<th class="text-right">${inputParam.cmd == 'R' ? '답장' : '전달'}</th>
								<td>
									<textarea id="reply_contents" name="reply_contents" class="form-control" style="height: 250px; overflow-y:scroll;" required="required" alt="${inputParam.cmd == 'R' ? '답장' : '전달'}">
${inputParam.cmd == 'F' ? '[전달]': ''}




--------------------Original message
보낸사람 : ${result.send_name}
보낸시간 : ${result.send_date}

${result.paper_contents}</textarea>
								</td>
							</tr>
							</c:if>
							<tr>
								<th class="text-right">첨부파일</th>
								<td>
									<div class="table-attfile file_div">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_L"/></jsp:include>&nbsp;&nbsp;
									</div>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /폼테이블 -->
				</div>
				<!-- /쪽지내용 -->
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
	<!-- 특수문자 -->
	<div class="popup-wrap width-300 mfp-hide" id="open_layer_specialChar" name="open_layer_specialChar" style="margin-top: -200px;">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<h2>특수문자선택</h2>
			<button type="button" class="btn btn-icon" onclick="javascript:fnLayerPopup()"><i class="material-iconsclose"></i></button>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="specialchar">
				<button type="button">☆</button>
				<button type="button">★</button>
				<button type="button">♡</button>
				<button type="button">♥</button>
				<button type="button">♧</button>
				<button type="button">♣</button>
				<button type="button">◁</button>
				<button type="button">◀</button>
				<button type="button">▷</button>
				<button type="button">▶</button>
				<button type="button">♤</button>
				<button type="button">♠</button>
				<button type="button">♧</button>
				<button type="button">♣</button>
				<button type="button">⊙</button>
				<button type="button">○</button>
				<button type="button">●</button>
				<button type="button">◎</button>
				<button type="button">◇</button>
				<button type="button">◆</button>
				<button type="button">⇔</button>
				<button type="button">△</button>
				<button type="button">▲</button>
				<button type="button">▽</button>
				<button type="button">▼</button>
				<button type="button">▒</button>
				<button type="button">▤</button>
				<button type="button">▥</button>
				<button type="button">▦</button>
				<button type="button">▩</button>
				<button type="button">◈</button>
				<button type="button">▣</button>
				<button type="button">◐</button>
				<button type="button">◑</button>
				<button type="button">♨</button>
				<button type="button">☏</button>
				<button type="button">☎</button>
				<button type="button">☜</button>
				<button type="button">☞</button>
				<button type="button">♭</button>
				<button type="button">♩</button>
				<button type="button">♪</button>
				<button type="button">♬</button>
				<button type="button">㉿</button>
				<button type="button">㈜</button>
				<button type="button">℡</button>
				<button type="button">㏇</button>
				<button type="button">±</button>
				<button type="button">㏂</button>
				<button type="button">㏘</button>
				<button type="button">€</button>
				<button type="button">®</button>
				<button type="button">↗</button>
				<button type="button">↙</button>
				<button type="button">↖</button>
				<button type="button">↘</button>
				<button type="button">↕</button>
				<button type="button">↔</button>
				<button type="button">↑</button>
				<button type="button">↓</button>
				<button type="button">∀</button>
				<button type="button">∃</button>
				<button type="button">∮</button>
				<button type="button">∑</button>
				<button type="button">∏</button>
				<button type="button">℉</button>
				<button type="button">‰</button>
				<button type="button">￥</button>
				<button type="button">￡</button>
				<button type="button">￠</button>
				<button type="button">Å</button>
				<button type="button">℃</button>
				<button type="button">♂</button>
				<button type="button">♀</button>
				<button type="button">∴</button>
				<button type="button">《</button>
				<button type="button">》</button>
				<button type="button">『</button>
				<button type="button">』</button>
				<button type="button">【</button>
				<button type="button">】</button>
				<button type="button">±</button>
				<button type="button">×</button>
				<button type="button">÷</button>
				<button type="button" style="font-family: dotum;">∥</button>
				<button type="button">＼</button>
				<button type="button">©</button>
				<button type="button">√</button>
				<button type="button">∽</button>
				<button type="button">∵</button>
			</div>
		</div>
	</div>
</form>
</body>
</html>
