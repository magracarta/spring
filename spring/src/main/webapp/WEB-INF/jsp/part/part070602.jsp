<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 출하시 지급품 관리 > 장비입고옵션 > null
-- 작성자 : 강명지
-- 최초 작성일 : 2020-01-20 15:38:15
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGridSec();
			createAUIGridSecRight();
			var total_cnt_first = AUIGrid.getRowCount(auiGridSec);
			$("#total_cnt_first").html(total_cnt_first);
		});
		
		//옵션관리창
		function goOptionName(execFuncName) {
			var param = {
				'parent_js_name' : execFuncName,
				'machine_name' : $M.getValue("s_machine_name"),
				'machine_plant_seq' : $M.getValue("machine_plant_seq"),
			};
			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=280, left=0, top=0";
			$M.goNextPage('/part/part0706p01', $M.toGetParam(param),{popupStatus : popupOption});
		}
		
		//받아온 값
		function setOptionName(data) {
		 	$("#s_opt_code").empty();
			var template = "";
			if(data.aui == '' || data.aui == undefined) {
				AUIGrid.updateRow(auiGridSec, {
					opt_cnt : '0',
					part_cnt : '0'
				}, AUIGrid.getRowIndexesByValue(auiGridSec, "machine_plant_seq", $M.getValue("machine_plant_seq"))); 
				$('#s_opt_code').attr('disabled', true);
				createAUIGridSecRight();
			} else {
				AUIGrid.updateRow(auiGridSec, {
					opt_cnt : data.list[0].opt_cnt,
					part_cnt :data.list[0].part_cnt
				}, AUIGrid.getRowIndexesByValue(auiGridSec, "machine_plant_seq", $M.getValue("machine_plant_seq"))); 
				$('#s_opt_code').removeAttr('disabled');
				var aui = data.aui;
				var lastIdx = aui.length-1;
				for(var i=0; i<lastIdx; i++){
					template += "<option value='"+aui[i].opt_code+"'>"+aui[i].opt_kor_name+"</option>";	
				}
				template += "<option value='"+aui[lastIdx].opt_code+"' selected='selected'>"+aui[lastIdx].opt_kor_name+"</option>";
				$("#s_opt_code").append(template);
				goSearchOpt(aui[lastIdx].opt_code);
			}
			
		}
		
		function goSave() {
			var validation = isValid();
			if(!validation) {	return;	}
			var distinction = isDistinct();
			if(!distinction) { 	return; }
			var removedItems = AUIGrid.getRemovedItems(auiGridSecRight);
			if(removedItems.length > 0) {
				var rowItem='';
				var idx='';
				for(i=0; i<removedItems.length; i++) {
					rowItem = removedItems[i];
					idx = AUIGrid.getRowIndexesByValue(auiGridSecRight, "_$uid", rowItem._$uid);
					console.log(idx);
					AUIGrid.restoreSoftRows(auiGridSecRight, idx); 
					AUIGrid.updateRow(auiGridSecRight, {
						use_yn : "N"
					}, idx
					);
				}
			}
			var frm = fnChangeGridDataToForm(auiGridSecRight);
			if(fnGetUpdatedItemsCnt(auiGridSecRight) == 0) {
				alert(msg.alert.data.noChanged);
				return;
			}
			var machine_plant_seq = $M.getValue("machine_plant_seq");
			$M.goNextPageAjaxSave(this_page + "/" + machine_plant_seq + "/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.updateRow(auiGridSec, {
							opt_cnt : result.list[0].opt_cnt,
							part_cnt :result.list[0].part_cnt
						}, AUIGrid.getRowIndexesByValue(auiGridSec, "machine_plant_seq", $M.getValue("machine_plant_seq")));
						alert("저장되었습니다.");
						goSearchIpgoOpt(machine_plant_seq);
					};
				}
			);
		}
		
		//널 체크
		function isValid() {
			return AUIGrid.validateGridData(auiGridSecRight, ["machine_plant_seq", "part_no", "part_name", "qty"], "각 항목에 값을 입력해주세요.");
		}
		
		//중복체크
		function isDistinct() {
			var data = AUIGrid.getGridData(auiGridSecRight);
			var disLength = '';
			var numQty = '';
			for(var i in data) {
				var subRows = data[i];
				disLength = AUIGrid.getItemsByValue(auiGridSecRight, "part_no", subRows.part_no);
				if(subRows.qty < 1) {
					alert("수량을 입력해주세요.");
					return false;
				}
				if(disLength.length > 1) {
					alert("부품이 중복됩니다. 확인하고 다시 시도하십시오.");
					return false;
				}
			}
			return true;
		}
		
		//상세조회
		function goSearchIpgoOpt(param) {
			$M.goNextPageAjax(this_page +"/opt/search/" + param, '', '',
				function(result) {
					if(result.success) {
						console.log(result);
						var data = result.list;
						$M.setValue("machine_plant_seq", param);
						$("#s_opt_code").empty();
						var template = "";
						$('#optionBtn').removeAttr('disabled');
						if(data.length == 0) {
							$('#s_opt_code').attr('disabled', 'true');
							AUIGrid.setGridData(auiGridSecRight, []);
						} else {
							$('#s_opt_code').removeAttr('disabled');
							for(var i=0; i<data.length; i++){
								template += "<option value='"+data[i].opt_code+"'>"+data[i].opt_kor_name+"</option>";	
							}
							$("#s_opt_code").append(template);
							goSearchOpt(data[0].opt_code);
						}
				}
			});
		}
		
		//장착 옵션 조회
		function goSearchOpt(param) {
			$M.goNextPageAjax(this_page +"/opt/search/" + $M.getValue("machine_plant_seq") + "/" + param, '', '',
					function(result) {
						if(result.success) {
							console.log(result)
							AUIGrid.setGridData(auiGridSecRight, result.list);
							$("#total_cnt").html(result.total_cnt);
					} 
				});
		}
		
		//행 추가
		function fnAdd() {
// 			var machineName = $M.getValue("s_machine_name");
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			var optCode = $M.getValue("s_opt_code");
			console.log(optCode);
			if(machinePlantSeq == "" || machinePlantSeq == "undefined") {	
				alert("장비 모델을 선택하고 행 추가를 진행해주세요.");
				return;	
			}
			if(optCode == "" || optCode == "undefined") {
				alert("추가할 장착옵션이 없습니다.");
				return;
			}
			var items = AUIGrid.getAddedRowItems(auiGridSecRight);
			if(items.length > 0) {
				alert("추가된 행을 저장하고 계속해주세요.");
			} else {
				var row = new Object();
// 				row.machine_name = machineName;
				row.machine_plant_seq = machinePlantSeq;
				row.opt_code = optCode;
				row.part_no = '';
				row.part_name = '';
				row.qty = '';
				row.delete_btn = '삭제';
				AUIGrid.addRow(auiGridSecRight, row, 'last');
			}
		}
		
		//부품 조회 값 받아옴
		function setPartInfo(rowArr) {
// 			var machineName = $M.getValue("s_machine_name");
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			var optCode = $M.getValue("s_opt_code");
			var partNo ='';
			var partName ='';
			var quantity ='';
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i<rowArr.length; i++) {
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					quantity = typeof rowArr[i].qty == "undefined" ? quantity : rowArr[i].qty;
// 					row.machine_name =  machineName;
					row.machine_plant_seq =  machinePlantSeq;
					row.part_no = partNo;
					row.part_name = partName;
					row.qty = quantity;
					row.opt_code = optCode;
					AUIGrid.addRow(auiGridSecRight, row, 'last');
				}
			}
		}
		
		//부품조회
		function goPartList() {
// 			var machineName = $M.getValue("s_machine_name");
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			var optCode = $M.getValue("s_opt_code");
			var items = AUIGrid.getAddedRowItems(auiGridSecRight);
			if(items.length > 0) {
				alert("추가된 행을 저장하고 시도해주세요.");
				return;
			}
			if(machinePlantSeq == "" || machinePlantSeq == "undefined") {	
				alert("장비 모델을 선택하고 행 추가를 진행해주세요.");
				return;	
			}
			if(optCode == "" || optCode == "undefined") {
				alert("추가할 장착옵션이 없습니다.");
				return;	
			}
			openSearchPartPanel('setPartInfo', 'Y');
		}
		
		//그리드 생성
		function createAUIGridSec() {
			//장비목록
			var gridProsSec = {
				rowIdField : "_$uid",
				enableFilter:true,
				rowStyleFunction : function(rowIndex, item) {
					if(item.sale_yn == "N") {
						return "aui-color-red";
					} 
				}
			};
			var columnLayoutSec = [
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					style : "aui-center aui-link",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "옵션수", 
					dataField : "opt_cnt", 
					style : "aui-center",
					width : "20%",
					editable : false,
				},
				{
					headerText : "구성수", 
					dataField : "part_cnt", 
					style : "aui-center",
					width : "20%",
					editable : false,
				},
				{
					headerText : "sale_yn", 
					dataField : "sale_yn", 
					style : "aui-center",
					editable : false,
				}
			];
			auiGridSec = AUIGrid.create("#auiGridSec", columnLayoutSec, gridProsSec);
			AUIGrid.setGridData(auiGridSec, ${list});
			$("#auiGridSec").resize();
			AUIGrid.bind(auiGridSec, "cellClick", function(event) {
				var machine_plant_seq = event.item.machine_plant_seq;
				$M.setValue("s_machine_name", event.item.machine_name);
				goSearchIpgoOpt(machine_plant_seq);
			});
			AUIGrid.hideColumnByDataField(auiGridSec, "sale_yn");
			AUIGrid.setFilterByValues(auiGridSec, "sale_yn", "Y");
		}
		
		function createAUIGridSecRight() {
			//장착옵션
			var stock_yn_list = ["YES", "NO"];
			var gridProsSecRight = {
				rowIdField : "_$uid",	
				editable : true,
				showStateColumn : true,
			};
			var columnLayoutSecRight = [
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					headerText : "장비명", 
					dataField : "machine_name",
					visible : false
				},
				{
					dataField : "opt_code",
					visible : false
				},				
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "25%",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "RemoteListRenderer",
						fieldName : "part_no",
						remoter : function( request, response ) { // remoter 지정 필수
							if(String(request.term).length < 2) {
								alert("2글자 이상 입력하십시오.");
								response(false); // 데이터 요청이 없는 경우 반드시 false 삽입하십시오.
								return;
							}
							var stock_mon = '${inputParam.s_current_mon}';
							var param = {
								"stock_mon" : stock_mon,
								"s_sort_key" : "tp.part_no", 
								"s_part_no" : request.term,
								"s_sort_method" : "desc",
								//"s_part_mng_cd" : "1"
							};
							$M.goNextPageAjax("/comp/comp0601" + "/search", $M.toGetParam(param), {method : 'get'},
								function(result) {
									if(result.success) {
										recentPartList = result.list;
										response(result.list); 
									};
								}
							);
						},
						noDataMessage : "데이터가 없습니다",
						listTemplateFunction : function(rowIndex, columnIndex, text, item, dataField, listItem) {
							var html = '';
							html += '<div class="myList-style">';
							html += '	<span class="myList-col" style="width:100px;">' + listItem.part_no + '</span>';
							html += '	<span class="myList-col" style="width:100px;">' + listItem.part_name + '</span>';
							html += '</div>';
							return html;
						}
					}
				},
				{
					headerText : "부품명", 
					dataField : "part_name", 
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "수량", 
					dataField : "qty", 
					style : "aui-editable",
					dataType : "numeric",
					width : "10%",
					editable : true,
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true
					}
				},
				{
					headerText : "삭제", 
					dataField : "delete_btn", 
					width : "10%",
					renderer : {
						type : "ButtonRenderer",
						labelText : "삭제", 
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridSecRight, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
								if(AUIGrid.isAddedById(auiGridSecRight, event.item._$uid)) {
									AUIGrid.removeSoftRows(event.pid, event.rowIndex);
								}
							} else {
								AUIGrid.restoreSoftRows(auiGridSecRight, "selectedIndex"); 
							}
						},
					},
					style : "aui-center",
					editable : false,
				},
				{
					dataField : "use_yn",
					visible : false
				}
			];
			auiGridSecRight = AUIGrid.create("#auiGridSecRight", columnLayoutSecRight, gridProsSecRight);
			AUIGrid.setGridData(auiGridSecRight, []);
			$("#auiGridSecRight").resize();
			AUIGrid.bind(auiGridSecRight, "cellEditBegin", function(event) {
				var rowIdField = AUIGrid.getProp(auiGridSecRight, "rowIdField");
				if(AUIGrid.isAddedById(auiGridSecRight, event.item[rowIdField])) {
		            return true;
			    } else if(event.dataField == 'qty') {
			    	return true;
			    }
			    return false; 
			});
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridSecRight, "cellEditEnd", auiCellEditHandler);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGridSecRight, "cellEditCancel", auiCellEditHandler);
		}
		
		//매출정지장비포함
		function fnSaleChange() {
			var saleYn = $("input:checkbox[id='sale_stop']").is(":checked"); 
			if(saleYn) {
				AUIGrid.setFilterByValues(auiGridSec, "sale_yn", ["Y", "N"]);
				total_cnt_first = AUIGrid.getRowCount(auiGridSec);
				$("#total_cnt_first").html(total_cnt_first);
			} else {
				AUIGrid.setFilterByValues(auiGridSec, "sale_yn", "Y");
				total_cnt_first = AUIGrid.getRowCount(auiGridSec);
				$("#total_cnt_first").html(total_cnt_first);
			}
		}
		
		// 편집 핸들러
		function auiCellEditHandler(event) {
// 			var machineName = $M.getValue("s_machine_name");
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			var optCode = $M.getValue("s_opt_code");
			switch(event.type) {
			case "cellEditEnd" :
				if(event.dataField == "part_no") {
					var partItem = getPartItem(event.value);
					if(typeof partItem === "undefined") {
						return;
					}
					// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
					AUIGrid.updateRow(auiGridSecRight, {
// 						machine_name : machineName,
						machine_plant_seq : machinePlantSeq,
						part_name : partItem.part_name,
						opt_code : optCode,
					}, event.rowIndex);
				}
				break;
			case "cellEditCancel" :
				if(event.dataField == "part_no") {
					if(typeof event.item.title == "undefined" || event.item.title == "") {
						//AUIGrid.removeRow(auiGrid, event.rowIndex);
					}
				}
				break;
			}
		}
		
		// part_no 으로 검색해온 정보 아이템 반환.
		function getPartItem(part_no) {
			var item;
			$.each(recentPartList, function(n, v) {
				if(v.part_no == part_no) {
					item = v;
					return false;
				}
			});
			return item;
		}
		
	</script>
</head>
<body>
<form id="main_form_sec" name="main_form_sec">
<input type="hidden" name="machine_plant_seq" id="machine_plant_seq">
<!-- contents 전체 영역 -->
		<div class="content-box" style="border: none !important;">
	<!-- 메인 타이틀 -->
	<!-- /메인 타이틀 -->
	<div class="contents">
			<div class="row">
<!-- 메뉴목록 -->
						<div class="col-4">
							<div class="title-wrap mt10">
								<div class="btn-group">
									<h4>장비목록</h4>
									<div class="right">
										<input type="checkbox" id="sale_stop" onchange="javascript:fnSaleChange();"/><label for="sale_stop">매출정지장비포함</label>
									</div>
								</div>						
							</div>
							<div id="auiGridSec" style="margin-top: 5px;height: 485px;"></div>
							<div class="btn-group mt5 custheight">		
								<div class="left">
									총 <strong class="text-primary" id="total_cnt_first">0</strong>건 
								</div>				
							</div>
						</div>
						<!-- /메뉴목록 -->						
						<div class="col-8">
						<div class="row">
								<div class="col-12">
									<div>
										<table class="table-border" style="margin-top: 15px;">
											<colgroup>
												<col width="100px"> <!-- 75에서 100으로수정-->
												<col width="300px">
												<col width="">
											</colgroup>
											<tbody>
												<tr>
													<th class="text-right">모델명</th>
													<td>
														<input type="text" class="form-control " id="s_machine_name" name="s_machine_name" readonly="readonly">
													</td>
												</tr>
												<tr>
													<th class="text-right">장착옵션</th>
													<td>
													<div class="form-row inline-pd">
															<div class="col-8">
																<select class="form-control" id="s_opt_code" name="s_opt_code" onchange="javascript:goSearchOpt(this.value);" disabled="disabled">
																</select>
															</div>
															<div class="col-auto">
																<button type="button" class="btn btn-primary-gra btn-cancel" id="optionBtn" onclick="javascript:goOptionName('setOptionName');" disabled="disabled">옵션명관리</button>
															</div>
														</div>
													</td>
												</tr>
											</tbody>
										</table>
									</div>
								<!-- 그리드 서머리, 컨트롤 영역 -->
									<div class="btn-group mt5 section-inner-center">					
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
										</div>
									</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
								</div>	
							</div>
							<div class="row">
								<!-- 메뉴정보 -->								
								<div class="col-12">
									<div class="title-wrap mt10">
										<div class="btn-group">
											<h4>장착옵션</h4>					
											<div class="right">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
											</div>
										</div>
									</div>									
									<!-- 폼테이블 -->	
									<div>
										<div id="auiGridSecRight" style="margin-top: 5px;height: 391px;"></div>
									</div>
<!-- /폼테이블 -->
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
<!-- /메뉴정보 -->									
							</div>

						</div>
					</div>
				</div>
			</div>
					
<!-- /contents 전체 영역 -->
</form>
</body>
</html>