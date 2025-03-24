<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 부품판매현황-센터별 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-08 16:18:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var today 	= "${inputParam.s_current_dt}";
		var mem_no  = "${SecureUser.mem_no}";
		var centerCd = [];
		
		$(document).ready(function() {
// 			fnInitDate();
			// 그리드 생성
			createLeftAUIGrid();		
			createRightAUIGrid();		
			goSearchPartList();
			
		});
		
// 		function fnInitDate() {
// 			$M.setValue('s_start_dt', $M.addMonths($M.toDate($M.getCurrentDate()), -1));
// 		}
		
		
		// 매입처 조회 팝업
		function fnSearchClientComm() {
			var param = {
				
			};
			openSearchClientPanel('fnSetClientInfo', 'comm', $M.toGetParam(param));
		}
		
		// 매입처 정보 세팅
		function fnSetClientInfo(row) {
			$M.setValue("s_cust_name", row.cust_name);
			$M.setValue("s_cust_no", row.cust_no);
		}
		
		// 매입처 정보 삭제
		function fnDeleteClientInfo() {
			$M.setValue("s_cust_name", "");
			$M.setValue("s_cust_no", "");
		}
		
		// 검색조건 부품조회set
		function goPartList() {
			var items = AUIGrid.getAddedRowItems(auiGridLeft);
			for (var i = 0; i < items.length; i++) {
				if (items[i].part_no == "") {
					alert("추가된 행을 입력하고 시도해주세요.");
					return;
				}
			}
			openSearchPartPanel('setPartInfo', 'Y');
		}
		
		
		// 선택한 로우 삭제
		function goRemoveRow() {
			// 상단 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridLeft);
			
			for (var i = 0; i < rows.length; ++i) {
				AUIGrid.removeRowByRowId(auiGridLeft, rows[i]._$uid);
				AUIGrid.removeSoftRows(auiGridLeft);
			}
		
			if(rows.length <= 0) {
				alert('삭제할 데이터가 없습니다.');
				return;
			};

		}
		
		
		// 부품조회 창에서 받아온 값
		function setPartInfo(rowArr) {
			// 부품조회 창에서 받아온 값 중복체크
			for (var i = 0; i < rowArr.length; i++ ) {
				var rowItems = AUIGrid.getItemsByValue(auiGridLeft, "part_no", rowArr[i].part_no);
				 if (rowItems.length != 0){
// 					 alert("부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.");
					 return "부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.";					 
				 }
			}
			
			var partNo 		= '';
			var partName 	= '';
			var partCurrent =  0;
			
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i<rowArr.length; i++) {
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					partCurrent = typeof rowArr[i].part_current == "undefined" ? partCurrent : rowArr[i].part_current;
					row.part_no = partNo;
					row.part_name = partName;
					row.current_stock = partCurrent;
					AUIGrid.addRow(auiGridLeft, row, 'last');
				}
			}
		}

		// 검색조건 부품목록
		function goSearchPartList() {
		
			var param = {
				"search_dt"		: today,
				"mem_no"		: mem_no,
			};

			
			$M.goNextPageAjax(this_page + "/searchPartList", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGridLeft, result.list);
						$("#left_total_cnt").html(result.total_cnt);
					};
				}
			);

		}
	
		
		// 검색조건 부품목록 조회
		function goSearch() {
			
			// 화면에 보여지는 그리드 데이터 목록
			var gridLeftList = AUIGrid.getGridData(auiGridLeft);
			
			var part_no = []; // 부품번호
			
			if(gridLeftList.length < 1) {
				alert("부품목록을 넣어주세요.");
				return;
			}
			
			for (var i = 0; i < gridLeftList.length; i++) {
				part_no.push(gridLeftList[i].part_no);
			}
				
			var option = {
				isEmpty : true
			};
			
			var s_dem_fore_yn		= "";
			
			if($("#s_dem_fore_yn").prop("checked")) {
				s_dem_fore_yn = 'Y';
			} else {
				s_dem_fore_yn = 'N';
			}
			
			var param = {
				"s_start_dt" 	: $M.getValue("s_start_dt"),
				"s_end_dt" 		: $M.getValue("s_end_dt"),
				"part_no_str" 	: $M.getArrStr(part_no, option),
				"inout_dt"		: $M.getValue("s_year"),
				"s_part_group_cd"		: $M.getValue("s_part_group_cd"),
				"s_deal_cust_no"		: $M.getValue("s_cust_no"),
				"s_dem_fore_yn"		: $M.getValue("s_dem_fore_yn"),
				"search_dt"		: today,
				"mem_no"		: mem_no
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/saveAndSearch", $M.toGetParam(param), {method : "POST"}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGridLeft);
						AUIGrid.resetUpdatedItems(auiGridLeft);
						var leftGridCnt = AUIGrid.getRowCount(auiGridLeft);
						$("#right_total_cnt").html(result.total_cnt);
						$("#left_total_cnt").html(leftGridCnt);
						
						if(result.list.length == 0) {
							alert("검색 결과가 없습니다.");
							return;
						};
						AUIGrid.setGridData(auiGridRight, result.list);
						
					};
				}
			); 
		}
		
		
		
		//  검색결과 부품목록 추가
		function goSearchAddPartList() {
			
			var s_cust_no 			= $M.nvl($M.getValue("s_cust_no"), ""); 
			var s_part_group_cd 	= $M.nvl($M.getValue("s_part_group_cd"), "");
			var s_dem_fore_yn		= "";
			
			if(s_cust_no == "" && s_part_group_cd == "") {
				alert("매입처 또는 부품그룹을 선택하세요.");
				return;
			};
			
			if($("#s_dem_fore_yn").prop("checked")) {
				s_dem_fore_yn = 'Y';
			} else {
				s_dem_fore_yn = 'N';
			}

			var param = {
				"s_part_group_cd"	: s_part_group_cd,
				"s_deal_cust_no"	: s_cust_no,
				"s_dem_fore_yn"		: s_dem_fore_yn,
			};
			
			$M.goNextPageAjax(this_page + "/searchAddPartList", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						
						if(result.list.length == 0) {
							alert("부품이 없습니다.");
							return;
						};
						
						var partList = [];
						for(i = 0; i < result.list.length; i++) {
							
							var rowItems = AUIGrid.getItemsByValue(auiGridLeft, "part_no", result.list[i].part_no);
							if (rowItems.length == 0) {
								partList[i] = {
									part_no : result.list[i].part_no,
						    		part_name : result.list[i].part_name,
						    		current_stock : result.list[i].current_stock,
						    		cmd : "C",		
								}
							}
						}
						
						AUIGrid.addRow(auiGridLeft, partList, "last");
						var leftGridCnt = AUIGrid.getRowCount(auiGridLeft);
						$("#left_total_cnt").html(leftGridCnt);
						
					};
				}
			);

		}
		
		// 행추가
		function fnAdd() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridLeft, "part_no");
			fnSetCellFocus(auiGridLeft, colIndex, "part_no");
			var item = new Object();
			if(fnCheckGridEmpty(auiGridLeft)) {
		    		item.part_no = "",
		    		item.part_name = "",
		    		item.current_stock = "",
		    		item.cmd = "C",
		    		AUIGrid.addRow(auiGridLeft, item, 'last');
			}	
		}
		
		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGridLeft, ["part_no", "part_name"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGridRight, "부품판매현황-센터별", "");
		}
		
		
		// 그리드생성
		function createLeftAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : true,
				showStateColumn : true,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				softRemoveRowMode : false,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "부품번호",
				    dataField: "part_no",
				    width : "35%", 
					style : "aui-center",
					editable : true,
					editRenderer : {				
						type : "ConditionRenderer", 
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							var param = {
									's_search_kind' : 'DEFAULT_PART',
									's_warehouse_cd' : "${SecureUser.org_code}",
									's_only_warehouse_yn' : "N",
									's_not_sale_yn' : "Y",		// 매출정지 제외
					    			's_not_in_yn' : "Y",			// 미수입 제외
					    			's_part_mng_cd' : ""
							};
							return fnGetPartSearchRenderer(dataField, param, auiGridLeft);
						},
					},
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					width : "50%",
					style : "aui-left",
					editable : false,
				},
				{
					headerText : "재고",
					width : "15%",
					dataField : "current_stock",
					style : "aui-right",
					editable : false,
				},
			
			];
	
			// 그리드 출력
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridLeft, []);
			$("#auiGridLeft").resize();
			
			// 추가행 에디팅 진입 허용
			AUIGrid.bind(auiGridLeft, "cellEditBegin", function (event) {
				if (event.dataField == "part_no") {
					if (AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						return false;
					};
				};
				
			});
			
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridLeft, "cellEditEndBefore", auiCellEditHandler);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridLeft, "cellEditEnd", auiCellEditHandler);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGridLeft, "cellEditCancel", auiCellEditHandler);
		}
		
		
		// 편집 핸들러
		function auiCellEditHandler(event) {
			switch(event.type) {
				case "cellEditEndBefore" :
					if(event.dataField == "part_no") {
						var isUnique = AUIGrid.isUniqueValue(auiGridLeft, event.dataField, event.value);	
						if (isUnique == false && event.value != "") {
							setTimeout(function() {
								   AUIGrid.showToastMessage(auiGridLeft, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
							}, 1);
							return "";
						} else {
							if (event.value == "") {
								return event.oldValue;							
							}
						}
					}
				
				break;
				case "cellEditEnd" :
					if(event.dataField == "part_no") {
						if (event.value == ""){
							return "";
						}
						// remote renderer 에서 선택한 값
						var item = fnGetPartItem(event.value);
						if(item === undefined) {
							AUIGrid.updateRow(auiGridLeft, {part_no : event.oldValue}, event.rowIndex);
						} else {
							
							// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
							AUIGrid.updateRow(auiGridLeft, {
								part_name : item.part_name,
								current_stock : item.current_stock,
							}, event.rowIndex);
						} 
				    }
				break;
			}
		};
		
		// part_no 으로 검색해온 정보 아이템(row) 반환 (엔터 or 마우스 클릭시 호출).
		function fnGetPartItem(part_no) {
			var item;
			$.each(recentPartList, function(index, row) {
				if(row.part_no == part_no) {
					item = row;
					return false; // 중지
				}
			});
	 		return item;
		 };
		
		// 그리드생성
		function createRightAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				// 고정칼럼 카운트 지정
				fixedColumnCount : 4,	// (Q&A 12738) 이태희씨 요청으로 부품번호, 부품명, 합계 틀고정 21.09.27 박예진
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "부품번호",
				    dataField: "part_no",
				    width : "130", 
				    minWidth : "130", 
					style : "aui-center"
				},
				{
					headerText : "부품명",
					dataField : "part_name",
				    width : "180", 
				    minWidth : "180", 
					style : "aui-left"
				},
				{
					headerText : "합계",
					children: [
						{
							headerText : "판매",
							dataField : "total_out_qty",
							dataType : "numeric",
							formatString : "#,##0",
						    width : "50", 
						    minWidth : "50", 
							style : "aui-right aui-popup",
						},
						{
							headerText : "재고",
							dataField : "total_stock_qty",
							dataType : "numeric",
							formatString : "#,##0",
						    width : "50", 
						    minWidth : "50", 
							style : "aui-right aui-popup",
						},
					]
				}
			];
			
			// 센터 목록 호출
			<c:forEach items="${centers}" var="item">
				var obj = {
					headerText : "${item[1]}",
					children: [
						{
							headerText : "판매",
							dataField : "${item[0]}" + "_out_qty",
							dataType : "numeric",
							formatString : "#,##0",
						    width : "50", 
						    minWidth : "50", 
							style : "aui-right aui-popup",
						},
						<c:if test="${item[0] eq '5110'}">
						{
							headerText : "재고",
							dataField : "6000" + "_stock_qty",
							dataType : "numeric",
							formatString : "#,##0",
						    width : "50", 
						    minWidth : "50", 
							style : "aui-right aui-popup",
						},
						</c:if>
						<c:if test="${item[0] ne '5110'}">
						{
							headerText : "재고",
							dataField : "${item[0]}" + "_stock_qty",
							dataType : "numeric",
							formatString : "#,##0",
						    width : "50", 
						    minWidth : "50", 
							style : "aui-right aui-popup",
						},
						</c:if>
						{
							dataField : "${item[0]}" + "_inout_org_code",
							visible : false
						},
					]
				}

				centerCd.push(${item[0]});
				columnLayout.push(obj);
			</c:forEach>
			
// 			 var addColumnObj = {
// 				headerText : "합계",
// 				children: [
// 					{
// 						headerText : "판매",
// 						dataField : "total_out_qty",
// 						dataType : "numeric",
// 						formatString : "#,##0",
// 					    width : "50", 
// 					    minWidth : "50", 
// 						style : "aui-right",
// 					},
// 					{
// 						headerText : "재고",
// 						dataField : "total_stock_qty",
// 						dataType : "numeric",
// 						formatString : "#,##0",
// 					    width : "50", 
// 					    minWidth : "50", 
// 						style : "aui-right",
// 					},
// 				]
//             };
			
// 			 columnLayout.push(addColumnObj);
			
			// 그리드 출력
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridRight, []);
			// AUIGrid.setFixedColumnCount(auiGridRight, 2);
			$("#auiGridRight").resize();
			
			AUIGrid.bind(auiGridRight, "cellClick", function(event) {

				var popupOption = "";
				var param = {
					"part_no" : event.item["part_no"],
					"s_assign_start_dt" : $M.getValue("s_start_dt"),
					"s_assign_end_dt" : $M.getValue("s_end_dt")
				};
				
				if(event.dataField.substr(4) == '_out_qty') {
					param.s_part_move_type_cd_in = "N";
					param.s_part_move_type_cd_out = "Y";
					param.s_part_move_type_cd_move = "N";
					var warehouseCd = event.dataField.substr(0, 4);
					param.warehouse_cd = warehouseCd == '5110' ? '6000' : warehouseCd;

					openInoutPartPanel('fnSetInoutPartInfo', $M.toGetParam(param));
				};

				if(event.dataField.substr(4) == '_stock_qty') {
					param.s_part_move_type_cd_in = "N";
					param.s_part_move_type_cd_out = "Y";
					param.s_part_move_type_cd_move = "N";
					openInoutPartPanel('fnSetInoutPartInfo', $M.toGetParam(param));
				};

				// 22.09.20 합계 내역 확인
				if(event.dataField == 'total_out_qty') {
					param.s_part_move_type_cd_in = "N";
					param.s_part_move_type_cd_out = "Y";
					param.s_part_move_type_cd_move = "N";
					openInoutPartPanel('fnSetInoutPartInfo', $M.toGetParam(param));
				};
				if(event.dataField == 'total_stock_qty') {
					param.s_part_move_type_cd_in = "Y";
					param.s_part_move_type_cd_out = "Y";
					param.s_part_move_type_cd_move = "Y";
					var warehouseCdList = "${warehouseCdList}";
					var login_org_code = "${inputParam.login_org_code}";
					if(warehouseCdList.indexOf(login_org_code) != -1){
						param.warehouse_cd = login_org_code == '5110' ? '6000' : login_org_code;
					}
					openInoutPartPanel('fnSetInoutPartInfo', $M.toGetParam(param));
				};

			});
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<div class="layout-box">
		<div class="content-wrap">
			<div class="content-box">
	<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
		<!-- /메인 타이틀 -->
		<!-- contents 전체 영역 -->
			<div class="contents">
				<!-- 검색영역 -->					
				<div class="search-wrap">		
					<table class="table table-fixed">
						<colgroup>
						<col width="70px">
						<col width="260px">					
						<col width="130px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
						
							<th>조회기간</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5" >
										<div class="input-group">
											<input type="text" class="form-control border-right-0  calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일" value="${searchDtMap.s_start_dt}">
										</div>
									</div>
									<div class="col-auto">~</div>
									<div class="col-5" >
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" value="${searchDtMap.s_end_dt}">
										</div>
									</div>
									<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
			                     		<jsp:param name="st_field_name" value="s_start_dt"/>
			                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
			                     		<jsp:param name="click_exec_yn" value="Y"/>
			                     		<jsp:param name="exec_func_name" value="goSearch();"/>
			                     		</jsp:include>	
								</div>
							</td>
							<td>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox" id="s_dem_fore_yn" name="s_dem_fore_yn" value="Y" checked="checked">
                                    <label class="form-check-label" for="s_dem_fore_yn">수요예측품만 조회</label>
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
	             <div class="row mt10">
	<!-- 좌측 테이블 -->
	                 <div class="col-4">
	                     <table class="table-border mt5">
	                         <colgroup>
	                             <col width="80px">
	                             <col width="">
	                         </colgroup>
	                         <tbody>
	                             <tr>
	                                 <th class="text-right">매입처</th>
	                                 <td>
	                                     <div class="form-row inline-pd widthfix pr">
	                                         <div class="col width140px">
	                                             <div class="input-group">
	                                                 <input type="text" class="form-control border-right-0" id="s_cust_name" name="s_cust_name" value="" alt="매입처명" readonly="readonly">
	                                                 <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>					
	                                             </div>
	                                                 <input type="hidden" class="form-control border-right-0" id="s_cust_no" name="s_cust_no" value="" alt="매입처번호">
	                                         </div>
	                                         <div class="col width33px">
	                                             <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnDeleteClientInfo();"><i class="material-iconsclose"></i></button>		
	                                         </div>	
	                                     </div>
	                                 </td>
	                             </tr>
	                             <tr>
	                            	<th>부품그룹</th>
									<td>
										<div class="input-group">
											<input type="text" style="width : 130px;" class="form-control border-right-0"
											id="s_part_group_cd" 
											name="s_part_group_cd" 
											easyui="combogrid"
											header="Y"
											easyuiname="groupCode" 
											panelwidth="360"
											maxheight="155"
											textfield="code"
											multi="N"
											enter=""
											idfield="code" />
											<div class="col width80px">
				                            	<button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchAddPartList();"><i class="material-iconsadd text-primary"></i> 부품추가</button>
			                                </div>	
										</div>
									</td>
	                             </tr>
	                         </tbody>
	                     </table>
	
	                     <div class="title-wrap mt10">
	                         <div class="text-right" style="flex: 1;">
	                             <button type="button" class="btn btn-default" onclick="javascript:goRemoveRow();">선택삭제</button>
	                             <button type="button" class="btn btn-important" onclick="javascript:goPartList();">부품검색</button>
	                             <button type="button" class="btn btn-default" onclick="javascript:fnAdd();">행추가</button>
	                         </div>
	                     </div>
	                     <div id="auiGridLeft" style="margin-top: 5px; height: 410px;"></div>
	                     <div class="btn-group mt5">	
	                         <div class="left">
	                             총 <strong class="text-primary" id="left_total_cnt">0</strong>건
	                         </div>
	                     </div>
	                 </div>
	<!-- /좌측 테이블 -->
	<!-- 우측 테이블 -->
	                 <div class="col-8">
	                     <div class="title-wrap">
	                         <div class="btn-group">
	                             <div class="right">
	                                 <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
	                             </div>
	                         </div>
	                     </div>
	                     <div id="auiGridRight" style="margin-top: 5px; height: 500px;"></div>
	                     <div class="btn-group mt5">	
	                         <div class="left">
	                             	총 <strong class="text-primary" id="right_total_cnt">0</strong>건
	                         </div>
	                     </div>
	                 </div>
	<!-- /우측 테이블 -->                       
	               </div>
			</div>
					
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>		
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>