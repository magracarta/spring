<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 렌탈장비대장 > null > 렌탈장비 렌탈이력
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		var auiGrid;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			$($("#menu_navi").children()[0]).html("${inputParam.machine_name} ${inputParam.body_no} 렌탈 이력");
		});
		
		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
			
 		    // 구해진 칼럼 사이즈를 적용 시킴.
			/* var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
		    AUIGrid.setColumnSizeList(auiGrid, colSizeList); */
		}
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row",
				showRowNumColumn: true
			};
			var columnLayout = [
				{
					headerText : "전표일자",
					dataField : "reg_date", 
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "75", 
					minWidth : "50", 
					style : "aui-center"
				},
				{
					headerText : "전표번호",
					dataField : "rental_doc_no", 
					width : "110", 
					minWidth : "100", 
					style : "aui-popup"
				},
				{ 
					headerText : "관리센터", 
					headerStyle : "aui-fold",
					dataField : "mng_org_name", 
					width : "55", 
					minWidth : "45",
					style : "aui-center"
				},
				{ 
					headerText : "메이커", 
					headerStyle : "aui-fold",
					dataField : "maker_name", 
					width : "55", 
					minWidth : "45",
					style : "aui-center"
				},
				{
					headerText : "모델명", 
					headerStyle : "aui-fold",
					dataField : "machine_name", 
					width : "65", 
					minWidth : "45",
					style : "aui-center"
				},
				{ 
					headerText : "차대번호", 
					headerStyle : "aui-fold",
					dataField : "body_no", 
					width : "170", 
					minWidth : "100",
					style : "aui-center"
				},
				{ 
					headerText : "연식", 
					headerStyle : "aui-fold",
					dataField : "made_dt", 
					width : "45", 
					minWidth : "35",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value.substring(0, 4);
					},
					style : "aui-center"
				},
				{ 
					headerText : "가동시간", 
					headerStyle : "aui-fold",
					dataField : "op_hour", 
					width : "55", 
					minWidth : "35",
					style : "aui-center",
					dataType : "numeric"
				},
				{ 
					headerText : "GPS", 
					headerStyle : "aui-fold",
					dataField : "gps_no", 
					width : "100", 
					minWidth : "100", 
					style : "aui-center"
				},
				{ 
					headerText : "등록번호", 
					headerStyle : "aui-fold",
					dataField : "mreg_no",					
					width : "90", 
					minWidth : "35",
					style : "aui-center"
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name",
					width : "65", 
					minWidth : "50", 
					style : "aui-center"
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no",
					width : "100", 
					minWidth : "100", 
					style : "aui-center"
				},
				{ 
					headerText : "접수자", 
					dataField : "receipt_mem_name", 
					width : "50", 
					minWidth : "50", 
					style : "aui-center"
				},
				{ 
					headerText : "렌탈시작", 
					dataField : "rental_first_st_dt", 
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "63", 
					minWidth : "50", 
					style : "aui-center"
				},
				{ 
					headerText : "렌탈종료", 
					dataField : "rental_first_ed_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "63", 
					minWidth : "50", 
					style : "aui-center"
				},
				{ 
					headerText : "렌탈기간", 
					dataField : "day_cnt",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value+"일";
					},
					width : "63", 
					minWidth : "50", 
					style : "aui-center"
				},
				{ 
					headerText : "렌탈금액", 
					dataField : "total_rental_amt",
					width : "100", 
					minWidth : "50", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "출고 시 가동시간",
					dataField : "min_op_hour",
					width : "100",
					minWidth : "50",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "회수 시 가동시간",
					dataField : "max_op_hour",
					width : "100",
					minWidth : "50",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "연장시작", 
					headerStyle : "aui-fold",
					dataField : "rental_ex_st_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "63", 
					minWidth : "50", 
					style : "aui-center"
				},
				{ 
					headerText : "연장종료", 
					headerStyle : "aui-fold",
					dataField : "rental_ex_ed_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "63",
					minWidth : "50", 
					style : "aui-center"
				},
				{ 
					headerText : "연장금액", 
					headerStyle : "aui-fold",
					dataField : "total_rental_ex_amt",
					width : "100", 
					minWidth : "50", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},	
				{ 
					headerText : "연장횟수", 
					headerStyle : "aui-fold",
					dataField : "rental_depth",
					width : "63", 
					minWidth : "50", 
				},	
				{ 
					headerText : "회수일", 
					headerStyle : "aui-fold",
					dataField : "return_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "63", 
					minWidth : "50", 
					style : "aui-center"
				},	
				{ 
					headerText : "회수자", 
					headerStyle : "aui-fold",
					dataField : "return_mem_name",
					width : "63", 
					minWidth : "50", 
				},					
				{ 
					headerText : "재렌탈차수", 
					headerStyle : "aui-fold",
					dataField : "rerental_num",
					width : "70", 
					minWidth : "50", 
					style : "aui-center"
				}			
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			// AUIGrid.setFixedColumnCount(auiGrid, 9);
			$("#auiGrid").resize();
			
			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}
			
			// 구해진 칼럼 사이즈를 적용 시킴.
			/* var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
		    AUIGrid.setColumnSizeList(auiGrid, colSizeList); */
		    
			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				//상태셀 선택한 겨우
				if(event.dataField == "rental_doc_no" ) {
					var params = {
						rental_doc_no : event.item.rental_doc_no
					}
					var popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
					$M.goNextPage("/rent/rent0102p01", $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
			
		}
		
	
		function fnDownloadExcel() {
	    	fnExportExcel(auiGrid, "렌탈이력", {});
	    }
			
		// 닫기
		function goClose() {
			window.close();
		}
		
		// 마스킹 체크시 조회
		function goSearch() {
			var param = {
					"rental_machine_no" : $M.getValue("rental_machine_no"),
					"rental_attach_no" : $M.getValue("rental_attach_no"),
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success){
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			); 
		}
	</script>
</head>
<body   class="bg-white"  >
<form id="main_form" name="main_form">
<input type="hidden" id="rental_attach_no" name="rental_attach_no" value="${inputParam.rental_attach_no}">
<input type="hidden" id="rental_machine_no" name="rental_machine_no" value="${inputParam.rental_machine_no}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title" id="menu_navi">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">				
			<div>
				<div class="title-wrap">
					<h4>렌탈이력</h4>	
					<div class="btn-group">
						<div class="right">
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
							<div class="form-check form-check-inline">
								<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" onchange="javascript:goSearch()">
								<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								
								<label for="s_toggle_column" style="color:black;">
									<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
								</label>
							</div>
							</c:if>
						</div>
					</div>
					<button type="button" class="btn btn-default"  onclick="javascript:fnDownloadExcel();" ><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
				</div>
				<div  id="auiGrid"  style="margin-top: 5px; height: 300px;"></div>
				<div class="btn-group mt10">
					<div class="left">
						총 <strong class="text-primary">${total_cnt }</strong>건
					</div>						
					<div class="right">
						<button type="button" class="btn btn-info" onclick="javascript:goClose();">닫기</button>
					</div>
				</div>
			</div>			
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>