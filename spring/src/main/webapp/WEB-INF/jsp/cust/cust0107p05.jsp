<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 견적서관리 > null > 즐겨찾는 견적서
-- 작성자 : 박예진
-- 최초 작성일 : 2021-05-03 14:30:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid", 
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				showStateColumn : true,
				editable : true,
				headerHeight : 40
			};
			var columnLayout = [
				{
					headerText : "즐겨찾기번호", 
					dataField : "rfq_part_fav_seq", 
					visible : false
				},
				{
					headerText : "견적서번호", 
					dataField : "rfq_no", 
					visible : false
				},
				{ 
					headerText : "견적제목", 
					dataField : "fav_name", 
					width : "220", 
					minWidth : "220", 
					style : "aui-left aui-editable",
					editable : true,
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "100", 
					minWidth : "100", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "견적금액<br>(VAT별도)", 
					dataField : "total_amt",
					width : "90", 
					minWidth : "90", 
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
				},
				{ 
					headerText : "할인율", 
					dataField : "discount_rate",
					width : "50", 
					minWidth : "50", 
					dataType : "numeric",
					formatString : "#,##0",
                    postfix: "%",
					style : "aui-right",
					editable : false,
				},
				{ 
					headerText : "할인금액", 
					dataField : "discount_amt",
					width : "90", 
					minWidth : "90", 
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
				},
				{ 
					headerText : "견적내역", 
					dataField : "count_remark",
					width : "280", 
					minWidth : "280", 
					style : "aui-left",
					editable : false,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if("${inputParam.sale_yn}" == "Y") {  
							return "aui-popup";
						} else {
							return "aui-left";
						}
					}
				},
				{
					headerText : "부서", 
					dataField : "org_name", 
					width : "100", 
					minWidth : "100", 
					style : "aui-center",
					editable : false
				},
				{
					headerText : "등록자", 
					dataField : "fav_mem_name", 
					width : "65", 
					minWidth : "65", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "등록일자", 
					dataField : "reg_dt",  
					width : "85", 
					minWidth : "85", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "정렬순서", 
					dataField : "row_no",  
					width : "55", 
					minWidth : "55", 
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "삭제", 
					dataField : "removeBtn", 
					width : "50", 
					minWidth : "50", 
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if("${inputParam.disabled_yn}" != "Y") {
								if (isRemoved == false) {
									AUIGrid.updateRow(auiGrid, { "part_use_yn" : "N" }, event.rowIndex);
									AUIGrid.removeRow(event.pid, event.rowIndex);
									AUIGrid.update(auiGrid);
								} else {
									AUIGrid.updateRow(auiGrid, { "part_use_yn" : "Y" }, event.rowIndex);
									AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
									AUIGrid.update(auiGrid);
								};
							}
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				},
				{ 
					dataField : "part_use_yn",  
					visible : false
				}
			];
	
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "count_remark") {
					if("${inputParam.sale_yn}" != "Y") {  
						return false;
					} else {
						// Row행 클릭 시 반영
						try{
							opener.${inputParam.parent_js_name}(event.item);
							window.close();	
						} catch(e) {
							alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
						}
					}
				}
			});
			
			$("#auiGrid").resize();
		}
		
		//조회
		function goSearch() { 
			var param = {
					"s_sort_key" : "rfq_part_fav_seq", 
					"s_sort_method" : "desc",
					"s_machine_name" : $M.getValue("s_machine_name"),
					"s_fav_name" : $M.getValue("s_fav_name"),
			};
			$M.goNextPageAjax('/cust/cust0107p02/searchFav', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		} 
		
		// 즐겨찾는 견적서 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			
			if (fnCheckGridEmpty() === false) {
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			};
			
			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxSave("/cust/cust0107p02/modifyFav", frm, {method : "POST"}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
						location.reload();
					};
				}
			); 
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["fav_name"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_fav_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "즐겨찾는 견적서", exportProps);
		}

	    //닫기
		function fnClose() {
			window.close(); 
		}	
	    
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
<!-- 검색영역 -->
            <div class="search-wrap mt5">				
                <table class="table table-fixed">
                    <colgroup>
                        <col width="65px">
                        <col width="160px">						
                        <col width="45px">
                        <col width="245px">
                        <col width="">
                    </colgroup>
                    <tbody>
                        <tr>
                            <th>견적제목</th>
                            <td>
                                <input type="text" class="form-control" name="s_fav_name" id="s_fav_name">
                            </td>
                            <th>모델</th>
                            <td>		
								<div class="form-row inline-pd pl5">
									<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
			                     		<jsp:param name="required_field" value=""/>
			                     		<jsp:param name="s_maker_cd" value=""/>
			                     		<jsp:param name="s_machine_type_cd" value=""/>
			                     		<jsp:param name="s_sale_yn" value=""/>
			                     		<jsp:param name="readonly_field" value=""/>
			                     		<jsp:param name="execFuncName" value=""/>
			                     		<jsp:param name="focusInFuncName" value=""/>
			                     	</jsp:include>
								</div>
							</td>	
                            <td>
                                <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                            </td>															
                        </tr>						
                    </tbody>
                </table>					
            </div>
<!-- /검색영역 -->            
            <div class="title-wrap mt10">
                <h4>견적제목</h4>
                <div class="btn-group">
                    <div class="right">
						<div class="form-check form-check-inline">
						<div class="text-warning ml5">
							※고객에 따라 VIP/일반 판매가가 다르게 적용됩니다. (할인율 적용)
						</div>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
                </div>
            </div>
			<div id="auiGrid" style="height:380px; margin-top: 5px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->	
</form>
</body>
</html>