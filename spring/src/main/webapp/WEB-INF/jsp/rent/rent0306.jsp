<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈비용 > 유지보수금액산출 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGridLeft;
		var auiGridRight;
		var gridRowIndex;
		var cntArr = [10000, 20000, 30000, 50000, 100000, 150000, 200000, 300000, 400000, 500000];
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridLeft();
			createAUIGridRight();
		});
		
		function fnDownloadExcel() {
			var exportProps = {
				// 제외항목
			    exceptColumnFields : ["delete_btn"]	
			};
			fnExportExcel(auiGridRight, "정비/공임항목", exportProps);
		}
	
		//그리드생성
		function createAUIGridLeft() {
			var gridPros = {
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				rowIdTrustMode : true,
				// rowNumber 
				showRowNumColumn : true,
				enableSorting : true,
				enableFilter : true
			};
			var columnLayout = [
				{ 
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "70", 
					minWidth : "60",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "100", 
					minWidth : "90",
					style : "aui-left aui-link",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "적용일",
					dataField : "apply_dt", 	
					dataType : "date",  
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					width : "75", 
					minWidth : "60",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				}
				
			];
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridLeft, []);
			$("#auiGridLeft").resize();
			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
				//모델명을 선택할 경우
				if(event.dataField == "machine_name" ) {
					var machinePlantSeq = event.item.machine_plant_seq;
					var applyDt = event.item.apply_dt;
					goDetail(machinePlantSeq, applyDt);
				}
			});
		}
		
		//그리드생성
		function createAUIGridRight() {
			var gridPros = {
				/* enableCellMerge : true, */
				editable : true,
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				rowIdTrustMode : true,
				// rowNumber 
				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true,
				editableOnFixedCell : true,
			};
			var columnLayout = [
				{ 
					headerText : "정비항목", 
					dataField : "rental_mro_type_name", 
					style : "aui-left",
					editable : false,
					width : "125", 
					minWidth : "120",
					renderer : {
						type : "TemplateRenderer"
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var template = value;
						if(("" != item.part_no && null != item.part_no)
								|| ("" == item.rental_mro_type_cd || null == item.rental_mro_type_cd)) {
							template = '<div style="width: 165px"><div style = "text-overflow: ellipsis; width: 140px; overflow-x: hidden; display: inline-block;">' + item.part_name +'</div><button type="button" class="icon-btn-search" onclick="javascript:fnSearchPart(' + rowIndex + ');" style="float: right;"> <i class="material-iconssearch"> </i></button></div>';
						}
						return template;
					}	
				},
				{
					headerText : "부품금액", 
					dataField : "part_price", 
					width : "75", 
					minWidth : "65",
					dataType : "numeric",
					style : "aui-right",
					editable : true,
					required : true,
					editRenderer : {
				    	type : "InputEditRenderer",
					    onlyNumeric : true,
			     	 	maxlength : 20
					},
					styleFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.rental_mro_type_cd != "24") {
							return "aui-editable";
						}
					},
				},
				{
					headerText : "부품수량",
					dataField : "part_qty", 		
					width : "75", 
					minWidth : "65", 
					style : "aui-center",
					dataType : "numeric",
					editRenderer : {
				    	type : "InputEditRenderer",
					    onlyNumeric : true,
			     	 	maxlength : 20
					},
					styleFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.rental_mro_type_cd == null || item.rental_mro_type_cd == "") {
							return "aui-editable";
						}
					},
					editable : true
				},
				{
					headerText : "공임항목(년별 횟수)",
					children : [
						{
							headerText : "10,000원", 
							dataField : "10000", 
							dataType : "numeric",
							width : "75", 
							minWidth : "65",
							style : "aui-right",
							editable : false,
							/* cellMerge : true,
							mergePolicy : "restrict",
							mergeRef : "myFake", */
						},
						{
							headerText : "20,000원", 
							dataField : "20000", 
							dataType : "numeric",
							width : "75", 
							minWidth : "65",
							style : "aui-right",
							editable : false,
						},
						{
							headerText : "30,000원", 
							dataField : "30000", 
							dataType : "numeric",
							width : "75", 
							minWidth : "65",
							style : "aui-right",
							editable : false,
						},
						{
							headerText : "50,000원", 
							dataField : "50000", 
							dataType : "numeric",
							width : "75", 
							minWidth : "65",
							style : "aui-right",
							editable : false,
						},
						{
							headerText : "100,000원", 
							dataField : "100000", 
							dataType : "numeric",
							width : "75", 
							minWidth : "65", 
							style : "aui-right",
							editable : false,
						},
						{
							headerText : "150,000원", 
							dataField : "150000", 
							dataType : "numeric",
							width : "75", 
							minWidth : "65",
							style : "aui-right",
							editable : false,
						},						
						{
							headerText : "200,000원", 
							dataField : "200000", 
							dataType : "numeric",
							width : "75", 
							minWidth : "65",
							style : "aui-right",
							editable : false,
						},
						{
							headerText : "300,000원", 
							dataField : "300000", 
							dataType : "numeric",
							width : "75", 
							minWidth : "65",
							style : "aui-right",
							editable : false,
						},
						{
							headerText : "400,000원", 
							dataField : "400000", 
							dataType : "numeric",
							width : "75", 
							minWidth : "65",
							style : "aui-right",
							editable : false,
						},
						{
							headerText : "500,000원", 
							dataField : "500000", 
							dataType : "numeric",
							width : "75", 
							minWidth : "65",
							style : "aui-right",
							editable : false,
						}
					]
				},
				{
					headerText : "전체합계",
					dataField : "part_amt",
					dataType : "numeric",
					width : "75", 
					minWidth : "65",
					style : "aui-right",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (item.rental_mro_type_cd != "90" && item.rental_mro_type_cd != "91") {
							return $M.setComma(value);
						}
					},
					editable : false,
				},
				{
					headerText : "삭제",
					dataField : "delete_btn",
					width : "45", 
					minWidth : "35",
					editable : false,
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridRight, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGridRight, {cmd : 'D'}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridRight, "selectedIndex");
								AUIGrid.updateRow(auiGridRight, {cmd : ''}, event.rowIndex);
							}
							updateCnt();
						},
						visibleFunction : function( rowIndex, columnIndex, value, item, dataField ) {
							if (item.rental_mro_type_cd != null && item.rental_mro_type_cd != "") {
								return false;
							} 
							return true;
						}, 
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					}
				},
				{ 
					dataField : "rental_mro_type_cd",
					visible : false
				},
				{ 
					dataField : "part_no",
					visible : false
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					dataField : "apply_dt",
					visible : false
				},
				{
					dataField : "seq_no",
					visible : false
				},
				{
					dataField : "cmd",
					visible : false
				},
				/* {
					dataField : "myFake",
					visible : false,
					cellMerge : true,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if (item.rental_mro_type_cd == "90" || item.rental_mro_type_cd == "91") {
							return 1;
						} else {
							return item._$uid;
						}
					}
				} */
			];
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, []);
			// AUIGrid.setFixedColumnCount(auiGridRight, 3);
			AUIGrid.bind(auiGridRight, "cellEditBegin", function(event) {
				if(event.dataField == "part_qty" && event.item.rental_mro_type_cd != null && event.item.rental_mro_type_cd != "") 
					return false; // false 반환. 기본 행위인 편집 불가
				if(event.dataField == "part_price" && (event.item.rental_mro_type_cd == "24")) {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridRight, event.rowIndex, event.columnIndex, "이 값은 호수교체(상하부)금액으로 결정됩니다.");
					}, 1);
					return false;
				} 
			});
			AUIGrid.bind(auiGridRight, "cellEditEnd", function(event) {
				if(event.dataField == "part_price") {
					if (event.item.rental_mro_type_cd == "90" || event.item.rental_mro_type_cd == "91") {
						try {
							// 호수교체상부 하부 부품가*수량 = 호수교체작업기 all
							var idx = AUIGrid.getRowIndexesByValue(auiGridRight, "rental_mro_type_cd", ["24"])[0];	
							var rows = AUIGrid.getRowsByValue(auiGridRight, "rental_mro_type_cd", ["90", "91"]);
							var tot = 0;
							for (var i = 0; i < rows.length; ++i) {
								tot += $M.toNum(rows[i].part_price) * $M.toNum(rows[i].part_qty);
							}
							AUIGrid.updateRow(auiGridRight, {part_price : tot}, idx);
							
							var len = cntArr.length;
							var _24Item = AUIGrid.getItemByRowIndex(auiGridRight, idx);
							for (var i = 0; i < len; ++i) {
								var al = $M.toNum(_24Item[cntArr[i]]);
								if (al != 0) {
									AUIGrid.updateRow(auiGridRight, {part_amt : (tot + cntArr[i]) * $M.toNum(_24Item[cntArr[i]])}, idx);
									break;
								}
							}
						} catch(e) {
							console.error(e);
						}
					}
				} 
				if (event.dataField == "part_price" || event.dataField == "part_qty") {
					var ret = "";
					var pPrice = $M.toNum(event.item.part_price);
					if (pPrice != 0) {
						if (event.item.rental_mro_type_cd != null && event.item.rental_mro_type_cd != "") {
							var len = cntArr.length;
							for (var i = 0; i < len; ++i) {
								var al = $M.toNum(event.item[cntArr[i]]);
								if (al != 0) {
									ret = ($M.toNum(event.item.part_price) + cntArr[i]) * $M.toNum(event.item[cntArr[i]]);
									break;
								}
							}
						} else {
							ret = $M.toNum(event.item.part_price) * $M.toNum(event.item.part_qty);
						}
					} else {
						ret = 0;
					}
					AUIGrid.updateRow(auiGridRight, {part_amt : ret}, event.rowIndex);
				}
			});
			$("#auiGridRight").resize();
		}	
		
 		// 부품조회(단일)
		function fnSearchPart(rowIdex) {
 			$M.setValue("clickedRowIndex", rowIdex);
			var param = {
				's_part_no' : $M.getValue('s_part_no'), 
			};
			openSearchPartPanel('fnSetPartInfo', 'N', $M.toGetParam(param));
		}

		// 부품조회 결과 test
		function fnSetPartInfo(row) {
			var rowIndex = $M.getValue("clickedRowIndex");
			AUIGrid.setCellValue(auiGridRight, rowIndex, "part_no", row.part_no);
			AUIGrid.setCellValue(auiGridRight, rowIndex, "part_name", row.part_name);
			AUIGrid.setCellValue(auiGridRight, rowIndex, "part_price", row.cust_price);
			AUIGrid.setCellValue(auiGridRight, rowIndex, "part_qty", 1);
			AUIGrid.setCellValue(auiGridRight, rowIndex, "part_amt", row.cust_price);
			AUIGrid.setCellValue(auiGridRight, rowIndex, "rental_mro_type_name", row.part_name);
			$("#auiGridRight").resize();
		}
		
		function updateCnt() {
			var cnt = 0;
			var rows =  AUIGrid.getGridData(auiGridRight);
			for (var i = 0; i < rows.length; ++i) {
				if (rows[i].cmd != "D") {
					++cnt;
				}
			}
			$("#right_total_cnt").html(cnt);
		}
		
		function goSearch() {
			$M.setValue("leftMachinePlantSeq", "");
			$M.setValue("leftApplyDt", "");
			var param = {
				"s_maker_cd" : $M.getValue("s_maker_cd")
				, "s_machine_plant_seq" : $M.getValue("s_machine_plant_seq")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#left_total_cnt").html(result.total_cnt);
						$("#right_total_cnt").html(0);
						AUIGrid.setGridData(auiGridLeft, result.list);
						AUIGrid.setGridData(auiGridRight, []);
					}
				}
			);
		}
		
		function goDetail(machinePlantSeq, applyDt) {
			$M.setValue("leftMachinePlantSeq", machinePlantSeq);
			$M.setValue("leftApplyDt", applyDt);
			var param = {
				"machine_plant_seq" : machinePlantSeq
				, "apply_dt" : applyDt
			};
			$M.goNextPageAjax(this_page + "/detail", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result);
						AUIGrid.setGridData(auiGridRight, []);
						AUIGrid.setGridData(auiGridRight, result.list);						
						$("#right_total_cnt").html(result.list.length);
						$("#auiGridRight").resize();
					}
				}
			);
		}

		// 행추가
		function fnAdd() {
			if("" == $M.getValue("leftMachinePlantSeq") || null == $M.getValue("leftMachinePlantSeq")) {
				alert("모델을 선택해주세요.");
				return false;
			}
			if(isValid()) {
				var row = {};
				row.machine_plant_seq = $M.getValue("leftMachinePlantSeq");
				row.apply_dt = $M.getValue("leftApplyDt");
				row.seq_no = '0';
				row.part_no = '';
				row.part_name = '';
				row.rental_mro_type_name = '-';
				row.part_price = '0';
				row.part_qty = '0';
				row.part_amt = '0';
				AUIGrid.addRow(auiGridRight, row, "last");
				var lastRow = AUIGrid.getGridData(auiGridRight).length-1;
	    		AUIGrid.setSelectionByIndex(auiGridRight, lastRow, 1);
	    		updateCnt();
			}
		}
		
		// 그리드 빈값 체크
		function isValid() {
			var data = AUIGrid.getGridData(auiGridRight);
			for(var i in data) {
				if (data[i].rental_mro_type_cd == null) {
					if ("" == data[i].part_no || null == data[i].part_no) {
						alert("정비항목을 입력해주세요.");
						return false;
					}
				}
			}
			return true;
		}
	
		// 저장
		function goSave() {
			
			// 왼쪽 그리드에서 모델 선택했는지
			var machinePlantSeq = $M.getValue("leftMachinePlantSeq");
			if("" == machinePlantSeq || null == machinePlantSeq) {
				alert("모델을 선택해주세요.");
				return false;
			}
			
			if(isValid() == false) {
				return false;
			}
			if(0 == fnChangeGridDataCnt(auiGridRight)) {
				alert("변경된 값이 없습니다.");
				return false;
			}
			var rows = AUIGrid.getGridData(auiGridRight);
			var totalAmt = 0;
			for (var i = 0; i < rows.length; ++i) {
				if (rows[i].cmd != "D") {
					totalAmt+=$M.toNum(rows[i].part_amt);
				}
			};
			var param = {
				total_amt : totalAmt,
				machine_plant_seq : $M.getValue("leftMachinePlantSeq"),
				apply_dt : $M.getValue("leftApplyDt"),
				seq_no_str : $M.getArrStr(rows, {sep : "#", key : "seq_no", isEmpty : true}),
				part_no_str : $M.getArrStr(rows, {sep : "#", key : "part_no", isEmpty : true}),
				part_qty_str : $M.getArrStr(rows, {sep : "#", key : "part_qty", isEmpty : true}),
				part_price_str : $M.getArrStr(rows, {sep : "#", key : "part_price", isEmpty : true}),
				part_amt_str : $M.getArrStr(rows, {sep : "#", key : "part_amt", isEmpty : true}),
				rental_mro_type_cd_str : $M.getArrStr(rows, {sep : "#", key : "rental_mro_type_cd", isEmpty : true}),
				cmd_str : $M.getArrStr(rows, {sep : "#", key : "cmd", isEmpty : true}),
			}
			console.log(param);
			$M.goNextPageAjaxSave(this_page + '/save', $M.toGetParam(param) , {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					}
				}
			);
		}
		
	</script>
</head>
<body>
<input type="hidden" id="clickedRowIndex" name="clickedRowIndex" value="">
<form id="main_form" name="main_form">
<input type="hidden" id="leftMachinePlantSeq" name="leftMachinePlantSeq" value="">
<input type="hidden" id="leftApplyDt" name="leftApplyDt" value="">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">			
<!-- 검색영역 -->					
					<div class="search-wrap">				
						<table class="table">
							<colgroup>							
								<col width="50px">
								<col width="75px">
								<col width="40px">
								<col width="160px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>메이커</th>
									<td>
										<select class="form-control" id="s_maker_cd" name="s_maker_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
													<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>
									<th>모델</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-12">
												<div class="input-group">
													<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
														<jsp:param name="required_field" value="s_machine_name"/>
														<jsp:param name="s_sale_yn" value="N"/>
							                     	</jsp:include>						
												</div>
											</div>	
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()"  >조회</button>
									</td>									
								</tr>						
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
					<div class="row">
						<div class="col-3">
<!-- 조회결과 -->
							<div class="title-wrap mt10">
								<h4>조회결과</h4>
							</div>
							<div id="auiGridLeft" style="margin-top: 5px; height: 555px;"></div>
							<div class="btn-group mt5">
								<div class="left">
									총 <strong class="text-primary" id="left_total_cnt">0</strong>건
								</div>
							</div>
<!-- /조회결과 -->
						</div>
						<div class="col-9">
<!-- 정비/공임항목 -->
							<div class="title-wrap mt10">
								<h4>정비/공임항목</h4>
								<div>
									<button type="button" id="_fnDownloadExcel" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
							<div  id="auiGridRight"  style="margin-top: 5px; height: 555px;"></div>
							<div class="btn-group mt5">
								<div class="left">
									총 <strong class="text-primary" id="right_total_cnt">0</strong>건
								</div>
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
								</div>
							</div>		
<!-- /정비/공임항목 -->							
						</div>
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