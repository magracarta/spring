<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품CUBE > null > SET조회
-- 작성자 : 박예진
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				treeColumnIndex : 2,
				headerHeight : 40,
				// 최초 보여질 때 모두 열린 상태로 출력 여부
				displayTreeOpen : false,		// 21.07.05 이진동님 요청으로 모두 닫힌 상태로 출력
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
// 				rowCheckableFunction : function(rowIndex, isChecked, item) {
// 					if(item.seq_depth == "2") {
// 						return false;
// 					}
// 					return true;
// 				},
				rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
					// 로그인한 사용자가 결재 권한이 없는 경우 체크박스 disabeld 처리
					if (item.seq_depth == "2") {
						return false;
					}

					return true;
				}
			};
			var columnLayout = [
				{ 
					headerText : "SET명", 
					dataField : "set_name", 
					width : "220",
					minWidth : "220",
					style : "aui-left",
				},
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "160",
					minWidth : "160",
					style : "aui-left"
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					width : "250",
					minWidth : "250",
					style : "aui-left"
				},				
				{ 
					headerText : "SET수량", 
					dataField : "qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{ 
					headerText : "현재고", 
					dataField : "current_stock",
					dataType : "numeric",
					formatString : "#,##0",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var qty = value;
						if(item["seq_depth"] == "1") {
							qty = "";
						}
				    	return $M.setComma(qty); 
					}
				},
				{ 
					headerText : "VIP가<br>(VAT별도)", 
					dataField : "vip_sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85", 
					style : "aui-right",
				},
				{ 
					headerText : "합계 VIP가", 
					dataField : "total_vip_sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85", 
					style : "aui-right",
				},
				{ 
					headerText : "일반가<br>(VAT별도)", 
					dataField : "sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85",
					style : "aui-right",
				},
				{ 
					headerText : "합계 일반가", 
					dataField : "total_sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85",
					style : "aui-right",
				},
				{ 
					headerText : "part_set_seq", 
					dataField : "part_set_seq", 
					visible : false
				},
				{ 
					headerText : "seq_depth", 
					dataField : "seq_depth", 
					visible : false
				},
				{ 
					headerText : "seq_no", 
					dataField : "seq_no", 
					visible : false
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}
		
		//조회
		function goSearch() { 
			var param = {
					"s_set_name" : $M.getValue("s_set_name"),
					"s_part_no" : $M.getValue("s_part_no"),
					"s_part_name" : $M.getValue("s_part_name"),
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
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
			var field = ["s_set_name", "s_part_no", "s_part_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGrid, "부품SET", exportProps);
		}
		
		// SET등록
		function goNew() {
			var popupOption = "";
			$M.goNextPage('/part/part070301p01', "",  {popupStatus : popupOption});
		}
		
		
		
		// 적용
		function goApply() {
			var gridData = AUIGrid.getCheckedRowItems(auiGrid);
			if(gridData.length == 0) {
				alert("체크한 데이터가 없습니다.");
				return;
			}
			
			var seqArr = []; 
			
			// 상위 뎁스 seq만 추가
			for(var i = 0; i < gridData.length; i++) {
				if(gridData[i].item.seq_depth == "1") {
					seqArr.push(gridData[i].item.part_set_seq);
				}	
			}
			
			var frm = $M.toValueForm(document.main_form);
			
			var option = {
				isEmpty : true
			};

			$M.setValue(frm, "part_set_seq_str", $M.getArrStr(seqArr, option));
			$M.setValue(frm, "warehouse_cd", $M.getValue("warehouse_cd"));

			$M.goNextPageAjax(this_page + "/searchPartSet", frm, {method : 'get'},
				function(result) {
					if(result.success) {
						if(result.qty_yn != "Y") {
							var msg = confirm("SET수량보다 현재고가 부족한 부품이 있습니다.\n추가하시겠습니까?");
							if(!msg) {
								return false;
							}
						}
						try{
							opener.${inputParam.parent_js_name}(result.list);
							fnClose();	
						} catch(e) {
							alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
						}
					}
				}
			);
		}

        // 닫기
        function fnClose() {
            window.close();
        }
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="cust_no" name="cust_no" value="${inputParam.cust_no}">
<input type="hidden" id="warehouse_cd" name="warehouse_cd" value="${inputParam.warehouse_cd}">
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
                        <col width="50px">
                        <col width="160px">						
                        <col width="65px">
                        <col width="100px">
                        <col width="55px">
                        <col width="100px">
                        <col width="">
                    </colgroup>
                    <tbody>
                        <tr>
                            <th>SET명</th>
                            <td>
                                <input type="text" class="form-control" id="s_set_name" name="s_set_name">
                            </td>
                            <th>부품번호</th>
                            <td>
                                <input type="text" class="form-control" id="s_part_no" name="s_part_no">
                            </td>
                            <th>부품명</th>
                            <td>
                                <input type="text" class="form-control" id="s_part_name" name="s_part_name">
                            </td>
                            <td>
                                <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                            </td>															
                        </tr>						
                    </tbody>
                </table>					
            </div>
<!-- /검색영역 -->
			<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>

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