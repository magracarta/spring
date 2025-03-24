<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 영업/관리/부품부 업무일지 상세
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
		var auiGridinner4;
		/* $(document).ready(function() {
			createauiGridinner4();

		}); */


		function createauiGridinner4() {
			var gridPros = {
				showRowNumColumn : true
			};

			var columnLayout = [
				{
					dataField : "duzon_trans_yn",
					visible : false
				},
				{
					dataField : "chain_no",
					visible : false
				},
				{
					dataField : "acnt_code",
					visible : false
				},
				{
					headerText : "카드번호",
					dataField : "card_no",
					width : "15%",
					style : "aui-center aui-popup"
				},
				{
					headerText : "승인일시",
					dataField : "approval_date",
					dataType : "date",
					width : "12%",
					formatString : "yy-mm-dd HH:MM:ss"
				},
				{
					headerText : "가맹점명",
					width : "12%",
					dataField : "chain_nm"
				},
				{
					headerText : "승인금액",
					dataField : "approval_amt",
					style : "aui-right",
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "사용자",
					dataField : "use_mem_name",
					width : "6%"
				},
				{
					headerText : "회계일자",
					dataField : "acnt_dt",
					width : "7%",
					dataType : "date",
					formatString : "yyyy-mm-dd"
				},
				{
					headerText : "계정과목",
					dataField : "acnt_name",
					width : "10%"
				},
				{
					headerText : "적요",
					dataField : "remark",
					style : "aui-left"
				},
				{
					headerText : "세액공제",
					dataField : "tax_dudect_yn",
					width : "5%",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var desc_text = value;
						if(item["tax_dudect_yn"] == "Y") {
							desc_text = "처리"
						} else {
							desc_text = "미처리"
						}
						return desc_text;
					}
				},
				{
					dataField : "imprest_status_cd",
					visible : false
				},
				{
					dataField : "aui_status_cd",
					visible: false
				},
				{
					dataField : "ibk_ccm_appr_seq",
					visible : false
				},
				{
					dataField : "card_code",
					visible: false
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridinner4 = AUIGrid.create("#auiGridinner4", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridinner4, []);
			AUIGrid.bind(auiGridinner4, "cellClick", function(event) {
				if(event.dataField == "card_no") {
					var param = {
						"ibk_ccm_appr_seq" : event.item.ibk_ccm_appr_seq 						
					};	
					var poppupOption = "";
// 					$M.goNextPage('/mmyy/mmyy0105p01', $M.toGetParam(param), {popupStatus : poppupOption});
					$M.goNextPage('/acnt/acnt0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
				} 
			});				
		}
	</script>

	<div  class="mt10">
		<div id="auiGridinner4" style="margin-top: 5px;"></div>
	</div>
