<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 영업/관리/부품부 업무일지 상세
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
		var auiGridinner5;
		/* $(document).ready(function() {
			createauiGridinner5();
		}); */


		function createauiGridinner5() {
			var gridPros = {
				showRowNumColumn : true
			};

			var columnLayout = [
				{
					dataField : "duzon_trans_yn",
					visible : false
				},
				{
					dataField : "account_link_cd",
					visible : false
				},
				{
					headerText : "전표번호",
					dataField : "inout_doc_no",
					width : "12%",
					editable : false,
					style : "aui-center aui-popup"
				},
				{
					headerText : "적요",
					editable : false,
					style : "aui-left",
					width : "15%",
					dataField : "remark",
				},
				{
					headerText : "입금",
					dataField : "deposit",
					editable : false,
					dataType : "numeric",
					style : "aui-right",
					formatString : "#,##0"
				},
				{
					headerText : "출금",
					dataField : "withdrawal",
					editable : false,
					dataType : "numeric",
					style : "aui-right",
					formatString : "#,##0"
				},
				{
					headerText : "잔액",
					dataField : "balance",
					editable : false,
					dataType : "numeric",
					style : "aui-right",
					formatString : "#,##0"
				},
		
				{
					headerText : "회계일자",
					dataField : "acnt_dt",
					editable : true,
					dataType : "date",
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						showEditorBtnOver : true
					},
					editable : true
				},
				{
					dataField : "acnt_name",
					headerText : "계정과목",
					style : "aui-center aui-editable",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						return value != null && value != "" ? value.replace(/\s/g,'') : "";
					},
					editable : false
				},
				{
					dataField : "acnt_code",
					visible : false
				},
				{
					headerText : "상태",
					dataField : "imprest_status_name",
					editable : false, // 그리드의 에디팅 사용 안함( 템플릿에서 만든 Select 로 에디팅 처리 하기 위함 )
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					}, 
					// dataField 로 정의된 필드 값이 HTML 이라면 labelFunction 으로 처리할 필요 없음.
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						var template = '<div>';
						if (value != "" && value != undefined) {
							template+= "<button class='btn btn-default'>"+value+"</button>";
						}
						template += '</div>';
						return template;
					}
				},
				{
					dataField : "imprest_status_cd",
					visible : false
				},
				{
					dataField : "datacase",
					visible : false
				},
				{
					dataField : "aui_status_cd",
					visible : false
				}
			];


			// 실제로 #grid_wrap에 그리드 생성
			auiGridinner5 = AUIGrid.create("#auiGridinner5", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridinner5, []);
			AUIGrid.bind(auiGridinner5, "cellClick", function(event) {
				$M.setValue("clickedRowIndex", event.rowIndex);
				if(event.item.inout_doc_no == ".") {
					return false;
				}
				if(event.dataField == "inout_doc_no") {
					if (event.item.datacase == "1") {
						var param = {
							inout_doc_no : event.value
						}
						var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=600, left=0, top=0";
						$M.goNextPage('/cust/cust0203p01', $M.toGetParam(param), {popupStatus : poppupOption});
					} else {
						var param = {
							imprest_doc_no : event.value
						}
						var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=600, left=0, top=0";
						$M.goNextPage('/acnt/acnt0102p01', $M.toGetParam(param), {popupStatus : poppupOption});	
					}
					
				} 

			});
		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner5" style="margin-top: 5px;"></div>
	</div>
