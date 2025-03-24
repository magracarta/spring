<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 쪽지함 > null > 쪽지상세
-- 작성자 : 이종술
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		/* 쪽지 내용 밑으로 떨어지게, 이미지는 원본말고 100%로*/
		p > img {
			width: 100%;
		}
		p {
			white-space: break-spaces;
		}
	</style>
	
	<script type="text/javascript">
	$(document).ready(function(){
		//발신자가 본인인 경우 답장기능 숨김
		if('${result.mem_no}' == '${SecureUser.mem_no}' ){
			$('#_goReply').hide();
		}
		
		//미결처리 플래그처리
		if('${result.confirm_yn}' == 'N'){
			$('#_goSave').text('미결처리저장');
		}else{
			$('#_goSave').text('미결처리해제');
		}
		
		//자료조회버튼 활성여부
		if('${result.pop_get_param}' == ''){
			$('#_goDataSearch').attr('disabled', true);
		}
		
		//다음 안읽은 쪽지있을경우
		if(${nextSeq} != 0){
			$('#_fnClose').text('확인');
		}
		
		$("#btnHideMid").children().eq(0).attr('id','btngoMove');
		$("#btnHideMid").children().eq(1).attr('id','btngoDataSearch');
		
		$('#btngoMove').css('margin-left','1px');
		$('#btngoDataSearch').css('margin-left','1px');
		
		if('${inputParam.s_paper_type}'=='SEND') {
			$("#_goSave").css("display", "none");
		}
		
		try {
			// 메인에 갱신
			opener.fnCntRenewal();
		} catch (e) {
			opener.parent.fnCntRenewal();
		}
	});
	
	function goSave() {

		var frm = document.main_form;	
		var msg = ( $M.getValue('confirm_yn') == 'Y' )? "미결상태를 해지 하시겠습니까?" : "미결상태로 변경 하시겠습니까?"; 
		
		$M.goNextPageAjaxMsg( msg ,this_page + "/confirm", frm, {method : 'post'},
				
			function(result) {
				if(result.success) {
					document.location.reload();
				};
			}
		);
	}

	function fnClose() {
		if(${nextSeq} != 0){
			var param = {
				"s_paper_seq" : ${nextSeq},
				"s_paper_type" : "RECEIVER",
			}
			$M.goNextPage('/mmyy/mmyy0102p02', $M.toGetParam(param), {method : 'GET'});
		}else{
			
			window.close();
    		<c:if test="${not empty inputParam.s_auto_papercheck}">
    			// opener.location.reload();
			</c:if>
			<c:if test="${not empty inputParam.s_paper_seq}">
				if (opener != null && opener.goSearch) {
					opener.goSearch();	
				}
			</c:if>
			
			
		}
	}

	function goReply() {
		// var param = {
		// 	"s_paper_seq" : $M.getValue('paper_seq'),
		// 	"cmd" : "R"
		// }
		// var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=760, left=0, top=0";
		// $M.goNextPage('/mmyy/mmyy0102p01/', $M.toGetParam(param), {popupStatus : poppupOption});


		var jsonObject = {
			"s_paper_seq" : $M.getValue('paper_seq'),
			"paper_contents" : "",
			"ref_key" : "",
			"receiver_mem_no_str" : "",	// 수신자
			"refer_mem_no_str" : "",		// 참조자
			"menu_seq" : "${result.menu_seq}",
			"pop_get_param" : "${result.pop_get_param}",
			"cmd" : "R"
		}
		openSendPaperPanel(jsonObject);
	}

	function goForward() {
		var param = {
			"s_paper_seq" : $M.getValue('paper_seq'),
			"cmd" : "F"
		}
		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=760, left=0, top=0";
		$M.goNextPage('/mmyy/mmyy0102p01/', $M.toGetParam(param), {popupStatus : poppupOption});
	}

	function goMove() {
		if($M.getValue('p_paper_box_seq') == ''){
			alert("이동할 쪽지함을 선택해주세요.");
			return;
		}
		
		var cmd = '${result.receiver_type}';
		if('${result.mem_no}' == '${SecureUser.mem_no}'){
			cmd = 'S'
		}
		
		var param = [{
			"paper_seq" : $M.getValue('paper_seq'),
			"paper_box_seq" : $M.getValue('p_paper_box_seq'),
			'mem_no' : '${SecureUser.mem_no}',
			'cmd' : cmd
		}];
		
		var frm = $M.jsonArrayToForm(param);
		
		$M.goNextPageAjax('/mmyy/mmyy0102/move', frm, {method : 'post'},
			function(result) {
				if(result.success) {
					$('#p_paper_box_seq').val('');
					try {
						if (window.opener.goSearch) {
							window.opener.goSearch();	
						}
					} catch(e) {
						console.error(e);
					}
				};
			}
		);
	}

	function goDataSearch() {
		if('${result.use_yn}' == 'N'){
			alert('해당메뉴는 사용할 수 없습니다.');
			return;
		}
		
		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=760, left=0, top=0";
		if('${result.pop_option_apply_yn}' == 'Y' && '${result.pop_option}' != ''){
			poppupOption = '${result.pop_option}';
		}
		
		var popGetParam = "${result.pop_get_param}";
		popGetParam = popGetParam.startsWith('as_no') ? "s_"+popGetParam : popGetParam;
		
		var url = '${result.url}';

		// 쪽지에서 연관된 페이지로 이동시킬때 해당페이지가 유효하지 않을때에는 미리 페이지 정보를 보고 JSON 오류메시지 일때, 유효하지 않는 페이지로 판단
		// 고과평가 자료참조시 post방식으로 자료참조 수정 21/07/06 이강원
		var postUrls = [
			'/acnt/acnt0605p01'
			, '/acnt/acnt0601p01'
		];
		var formMethod = postUrls.includes(url) ? 'POST' : 'GET';

		$M.goNextPageAjax(url, popGetParam, {dataType : 'html', method : formMethod}, function(result) {
			var error = result.indexOf("{\"result_code\":\"500\"") > 0 || result.indexOf("{\"result_code\":\"-1\"") > 0;
			if (error) {
				alert("해당 자료가 삭제되었거나, 유효하지 않습니다.");
			} else {
				if (formMethod === 'POST') {
					// 1초안에 두번 이상 POST 호출 시, 중복요청 필터링에 걸리므로 1초 대기 처리
					setTimeout(() => $M.goNextPage(url, popGetParam, {popupStatus : poppupOption, method : formMethod}), 1000);
				} else {
					$M.goNextPage(url, popGetParam, {popupStatus : poppupOption, method : formMethod});
				}
			}
		});
	}
	</script>
</head>
<body class="bg-white" >
<form id="main_form" name="main_form">
<input type="hidden" id="paper_seq" name="paper_seq" value="${result.paper_seq }">
<input type="hidden" id="confirm_yn" name="confirm_yn" value="${result.confirm_yn }">
<input type="hidden" id="receiver_type" name="receiver_type" value="${result.receiver_type }">

<div class="popup-wrap width-100per">
<!-- contents 전체 영역 -->
	<div class="content-wrap" style="padding: 0">
	<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
	<!-- /메인 타이틀 -->
		<div class="content-wrap">
			<div>
				<div class="title-wrap">
					<div class="left">
						<h4>받은쪽지</h4>
					</div>
					<div class="right dpf">
						<select class="form-control mr5" style="width: 150px;" id="p_paper_box_seq" name="p_paper_box_seq">
							<option value="">==전체==</option>
							<c:forEach var="data" items="${box }">
								<option value="${data.paper_box_seq }">${data.box_name }</option>
							</c:forEach>
						</select>
						<%--<button type="button" class="btn btn-default mr5">이동</button>
						<button type="button" class="btn btn-default">자료조회</button>--%>
						<div id="btnHideMid">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<!-- 폼테이블 -->
				<div>
					<table class="table-border mt5">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">보낸이</th>
							<td>${result.send_name }</td>
							<th class="text-right">보낸날짜</th>
							<td><fmt:formatDate value="${result.send_date}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
						</tr>
						<tr>
							<th class="text-right">수신자</th>
							<td colspan="3">${result.receiver_name }</td>
						</tr>
						<tr>
							<th class="text-right">참조자</th>
							<td colspan="3">${result.cc_name }</td>
						</tr>
						<tr>
							<th class="text-right">첨부파일</th>
							<td colspan="3">
								<div class="table-attfile">
									<c:forEach var="data" items="${file }">
										<div class="table-attfile-item">
											<span class="text-primary"><a href="javascript:void(0);" onclick="javascript:fileDownload('${data.file_seq}');" >${data.file_name }</a></span>
										</div>
									</c:forEach>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">쪽지내용</th>
							<td colspan="3" class="v-align-top" style="height: 200px;">
								<pre style="white-space: break-spaces;">${result.paper_contents }</pre>
							</td>
						</tr>
						<tr>
							<th class="text-right">답장내용</th>
							<td colspan="3" class="v-align-top" style="height: 200px;">
								<pre style="white-space: break-spaces;">${result.reply_paper_contents }</pre>
							</td>
						</tr>
						
						</tbody>
					</table>
				</div>
				<!-- /폼테이블 -->
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
		</div>
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>