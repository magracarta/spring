<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > 공통업무팝업 > null > 문자발송내역조회
-- 작성자 : 박준영
-- 최초 작성일 : 2020-10-12 15:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			fnInitDate();
			fnSetParam();
			createAUIGrid();		
		});
		
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "$uid",
				rowStyleFunction : function(rowIndex, item) {
					if(item.send_limit_yn == "Y") {
					   return "smsRestricted";
					};
				}
			};
			var columnLayout = [
				{
					dataField : "sms_send_seq", 
					visible : false
				},
				{
					headerText : "전송일시", 
					dataField : "send_date", 
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					width : "13%", 
					style : "aui-center",
				},
				{
					headerText : "수신", 
					dataField : "receiver_name", 
					width : "8%", 
					style : "aui-center",
				},
				{
					headerText : "수신번호", 
					dataField : "phone_no", 
					width : "8%", 
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {					
						if(value != ""){
							return $M.phoneFormat(value);
						}
					}	
				},
				{
					headerText : "전송내용", 
					dataField : "msg", 
					width : "20%", 
					style : "aui-left"
				},
				{
					headerText : "발송", 
					dataField : "reg_mem_name", 
					width : "8%", 
					style : "aui-center"
				},
				{
					headerText : "회신번호", 
					dataField : "callback_no", 
					width : "8%", 
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {					
						if(value != ""){
							return $M.phoneFormat(value);
						}
					}	
				},
				{
					dataField : "proc_ypn",
					visible : false
				},
				{
					headerText : "전송상태", 
					dataField : "proc_ypn_name"
				},
				{
					headerText : "처리결과", 
					dataField : "sms_result_cd", 
					width : "8%", 
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						if((item.sms_result_cd == "06" ||  item.sms_result_cd == "1000" ) && item.proc_ypn == 'Y') {
							return "성공";
						}
						else if (item.sms_result_cd != "06" && item.sms_result_cd != "1000" && item.proc_ypn == 'Y') {
							return "실패";
						}
						else {
							return "";
						}
					}
				},
				{
					headerText : "사유", 
					dataField : "sms_result_name", 
					width : "10%", 
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						return (item.sms_result_cd == "06" ||  item.sms_result_cd == "1000" ) ? "" : value; 
					}
				},
				{
					headerText : "발송제한", 
					dataField : "send_limit_yn", 
					width : "5%", 
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						//사용자가 체크 상태를 변경하고자 할 때 변경을 허락할지 여부를 지정할 수 있는 함수 입니다.
						checkableFunction :  function(rowIndex, columnIndex, value, isChecked, item, dataField ) {
							if( (item.sms_result_cd != "06" &&  item.sms_result_cd != "1000" )  && item.proc_ypn == 'Y') {
								return true;
							}
							return false;
						},
						// 체크박스 disabled 함수
						disabledFunction : function(rowIndex, columnIndex, value, isChecked, item, dataField) {
							if( (item.sms_result_cd != "06" &&  item.sms_result_cd != "1000" ) && item.proc_ypn == 'Y') {
								return false; 
							}							
							return true;
						},
						checkValue : "Y",
						unCheckValue : "N"
					}
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);

		}
		
		//날짜초기화
		function fnInitDate() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
		}
		
		// 받아온 정보 셋팅
		function fnSetParam() {
			
			var receiver_name 	= $M.nvl("${inputParam.receiver_name}", "");
			var phone_no 		= $M.nvl("${inputParam.phone_no}", "");			
			var params = {
					s_receiver_name : receiver_name,
	    			s_phone_no 	  : phone_no,		
	    	};			
			$M.setValue(params);
		}

		function goSearch() {
		
			if ($M.validation(document.main_form) == false) {
				return;
			};
			
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			}; 
			
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_receiver_name : $M.getValue("s_receiver_name"),
				s_phone_no : $M.getValue("s_phone_no"),
				s_proc_ypn : $M.getValue("s_proc_ypn"),
				s_sort_key : "send_date", 
				s_sort_method : "desc",
			};

			console.log(param);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					};
				}
			);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_receiver_name", "s_phone_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		// 팝업닫기
		function fnClose() {
			window.close(); 
		}
		
		
		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			
			var frm = fnChangeGridDataToForm(auiGrid);
			console.log(frm);
			
			
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : "POST"}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					};
				}
			); 
		}
		
		
		
	</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
	<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	        <div class="main-title">
	            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	        </div>
	<!-- /타이틀영역 -->
	        <div class="content-wrap">	  
	<!-- 검색조건 -->
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="65px">
							<col width="260px">
							<col width="55px">
							<col width="120px">
							<col width="75px">
							<col width="120px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>조회기간</th>
								<td>
									<div class="form-row">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="시작일" required="required">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" alt="종료일" value="${inputParam.s_current_dt}" required="required">
											</div>
										</div>
									</div>
								</td>
	
								<th>수신자명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_receiver_name" name="s_receiver_name" maxlength="10" alt="수신자명">
									</div>
								</td>
								<th>수신자번호</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_phone_no" name="s_phone_no" maxlength="12" alt="수신자 번호" >
									</div>
								</td>
								<th>전송상태</th>
								<td>
									<select class="form-control" id="s_proc_ypn" name="s_proc_ypn">
										<option value="">전체</option>
										<option value="N">전송대기</option>
										<option value="P">전송중</option>
										<option value="Y">전송완료</option>
									</select>
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:goSearch();">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
	<!-- /검색조건 -->
	<!-- 검색결과 -->
				<div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>
				<div class="btn-group mt5">
					총 <strong class="text-primary" id="total_cnt">0</strong>건 
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	<!-- /검색결과 -->
	<!-- 발송제한 안내사항 -->
				<div class="alert alert-secondary mt10">
					<div class="title">
						<i class="material-iconserror font-16"></i>
						발송제한 안내사항
					</div>
					<ul>
						<li>발송 제한 체크 시 해당 수신 번호는 개별 또는 그룹별 문자전송 시 발송에서 제한됩니다.</li>
					</ul>                    
				</div>
	<!-- /발송제한 안내사항 -->
	
	        </div>
	    </div>
	<!-- /팝업 -->
	</form>
</body>
</html>