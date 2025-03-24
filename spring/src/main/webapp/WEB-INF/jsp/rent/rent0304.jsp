<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈비용 > 렌탈기준정보-어태치먼트 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var hasAll = false;
		var machineSubTypeMap = ${machineSubTypeMap};  // 기종에따른 규격 LIST
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			// 취득세율, 이자율, 장비가(대리점가) 입력시 계산
			$(".formula").each(function() {
				$(this).keydown(function(event){
					if("" == $M.getValue("part_no")) {
// 						fnNew();
						alert("어태치먼트를 선택해 주세요.");
						return false;
					} else {
						fnFormula();
					}
				});
			});
			goSearch();
		});
		
		function goSearchPart() {
			var param = {
				/* partReadOnlyField : "s_part_mng_cd", */
				s_part_mng_cd : 90,
				s_search_rental_part_yn : "Y"
			}
			openSearchPartPanel('setPartInfo', 'N', $M.toGetParam(param));
		}
	
		//그리드생성
		function createAUIGrid() {
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
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "100", 
					minWidth : "90",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name",
					width : "140", 
					minWidth : "130",
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "어태치먼트명", 
					dataField : "attach_name", 
					width : "100", 
					minWidth : "90",
					style : "aui-left aui-link",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "적용모델명", 
					dataField : "machine_name",
					width : "300",
					minWidth : "150",
					style : "aui-left",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return value == "" ? "공용" : value; 
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "구매가격",
					dataField : "buy_price", 	
					width : "100", 
					minWidth : "90",
					style : "aui-right",
					dataType : "numeric",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					width : "80",
					minWidth : "80",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "attach_name" ) {
					fnNew();
					goDetail(event.item.part_no);
				}
			});

			// AUIGrid.setFilterCache(auiGrid, {"use_yn" : ["Y", "N"]});
		}
		
		function enter(fieldObj) {
			var field = ["s_machine_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
			
		// 목록조회
		function goSearch() {
			var param = {
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
						fnNew();
						AUIGrid.setFilterByValues(auiGrid, "use_yn", "Y");
					}
				}
			);
		}
		
		// 상세조회
		function goDetail(part_no) {
			hasAll = false;
			$M.goNextPageAjax(this_page + "/search/" + part_no, null, {method : 'get'},
				function(result) {
					if(result.success) {
						fnSetDetail(result.item);
						fnFormula();
					}
				}
			);
		}
	
		// 신규 (폼 초기화)
		function fnNew() {
			// 어태치먼트 조회 버튼 활성화
			$("#partSearchbtn").prop("disabled", false);
			$M.clearValue({field:[
				"part_name"
				, "part_no"
				, "machine_name"
				, "attach_name"
				, "machine_plant_seq"
				, "reg_tax_rate"
				, "reg_tax_amt"
				, "interest_rate"
				, "interest_amt"
				, "buy_price"
				, "proc_time_month"
				, "proc_time_year"
				, "part_total_amt"
				, "attach_price"
				, "mon_rental_price"
				, "min_sale_price"
				, "machine_type_cd"
			]});
			$M.setValue("base_yn", "N");
			$M.setValue("cost_yn", "Y");
			$M.setValue("use_yn", "Y");
			$M.setValue("year_mro_amt", "0");
			$("#machine_sub_type_cd").combogrid("setValues", []);
		}
		
		// 상세 정보 세팅 (폼 세팅)
		function fnSetDetail(item) {
			// 어태치먼트 조회 버튼 비활성화
			$("#partSearchbtn").prop("disabled", true);
			$M.setValue(item);

			if($M.getValue("machine_sub_type_cd_str") == ""){
				// 콤보그리드 다시 세팅
				$("#machine_sub_type_cd").combogrid("grid").datagrid("loadData", []);
				$("#machine_sub_type_cd").combogrid("setValues", []);
			} else {
				var machineSubTypeCd = item.machine_sub_type_cd_str;
				var subTypeArr = machineSubTypeCd.split("#");
				$("#machine_sub_type_cd").combogrid("setValues", []);
				// 콤보그리드 다시 세팅
				$("#machine_sub_type_cd").combogrid("grid").datagrid("loadData", machineSubTypeMap[$M.getValue("machine_type_cd")]);
				$("#machine_sub_type_cd").combogrid("setValues", subTypeArr);
			}



			$M.setValue("proc_time_month", item.proc_time_month || "0");
		}

		// 저장
		function goSave() {
			var part_no = $M.getValue("part_no");
			if(part_no == "") {
				alert("어태치먼트를 선택해 주세요");
				return;
			}

			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			}

			var params = {
				"part_no" : $M.getValue("part_no"),
				"attach_name" : $M.getValue("attach_name"),
				"buy_price" : $M.getValue("buy_price"),
				"reg_tax_rate" : $M.getValue("reg_tax_rate"),
				"interest_rate" : $M.getValue("interest_rate"),
				"interest_amt" : $M.getValue("interest_amt"),
				"reg_tax_amt" : $M.getValue("reg_tax_amt"),
				"attach_price" : $M.getValue("attach_price"),
				"machine_type_cd" : $M.getValue("machine_type_cd"),
				"machine_plant_seq" : '0',
				"machine_sub_type_cd_str" : $M.getValue("machine_sub_type_cd"),
				"year_mro_amt" : $M.getValue("year_mro_amt"),
				"base_yn" : $M.getValue("base_yn"),
				"cost_yn" : $M.getValue("cost_yn"),
				"use_yn" : $M.getValue("use_yn"),
			}

			$M.goNextPageAjaxSave(this_page + '/save', $M.toGetParam(params) , {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					}
				}
			);
		}
	
		// 삭제
		function goRemove() {
			var part_no = $M.getValue("part_no");
			if(part_no == "") {
				alert("어태치먼트를 선택해 주세요");
				return;
			}
			var param = {
				"part_no" : part_no
			};
			$M.goNextPageAjaxRemove(this_page + '/remove', $M.toGetParam(param) , {method : 'POST'},
				function(result) {
					if(result.success) {
						fnNew();
					}
				}
			);
		}
		
		// 엑셀 다운로드
		function fnDownloadExcel() {
			// 제외항목
		 	var exportProps = {};
			fnExportExcel(auiGrid, "렌탈기준정보-어태치먼트", exportProps);
		}
		
		// 상세정보 모델 조회팝업 선택값 세팅
		function setMachineInfo(data) {
			$M.setValue("machine_name", data.machine_name);
			$M.setValue("machine_plant_seq", data.machine_plant_seq);
		}
		
		// 상세정보 어태치먼트 조회팝업 선택값 세팅
		function setPartInfo(data) {
			
			var param = {
				"s_maker_cd" : "",
				"s_machine_plant_seq" : ""
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						var rows = result.list;
						for (var i = 0; i < rows.length; ++i) {
							if (rows[i].part_no == data.part_no) {
								alert("이미 등록된 어태치먼트입니다.");
								return false;
							}
						} 
						$M.setValue("part_name", data.part_name);
						$M.setValue("part_no", data.part_no);
						// 운영기간
						$M.setValue("proc_time_month", "0");
						$M.setValue("proc_time_year", "0");
					}
				}
			);
		}
		
		// 산식
		function fnFormula() {
			var price = $M.toNum($M.getValue("buy_price"))
			var taxR = $M.toNum($M.getValue("reg_tax_rate"));
			
			var taxA = (taxR/100) * price;
			var iR = $M.toNum($M.getValue("interest_rate"));
			var iA = (iR/100) *  price;
			var ap = price + iA;
			var param = {
				reg_tax_amt : taxA,
				interest_amt : iA,
				attach_price : ap,
				year_mro_amt : 0
			}
			$M.setValue(param);
		}

		// 렌탈기본장착어테치 관리
		function goSetting() {
			var param = {};
			var popupOption = "";
			$M.goNextPage('/rent/rent0304p01', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 적용장비모델명 수정
		function fnChangeMachine() {
			$("#machine_sub_type_cd").combogrid("setValues", []);
			// 콤보그리드 다시 세팅
			if($M.getValue("machine_type_cd") != "" ){
				$("#machine_sub_type_cd").combogrid("grid").datagrid("loadData", machineSubTypeMap[$M.getValue("machine_type_cd")]);
			} else {
				$("#machine_sub_type_cd").combogrid("grid").datagrid("loadData", []);
			}
			// if(!hasAll && nowAll) {
			// 	$("#machine_plant_seq").combogrid("setValues","0");
			// 	hasAll = true;
			// } else if(hasAll && mchArr.length > 1){
			// 	for( var i = 0; i < mchArr.length; i++){
			// 		if ( mchArr[i] == '0') {
			// 			mchArr.splice(i, 1);
			// 		}
			// 	}
			// 	$("#machine_plant_seq").combogrid("setValues", mchArr.join("#"));
			// 	hasAll = false;
			// }
		}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- <input type="hidden" name="part_total_amt" value="0">
<input type="hidden" name="total_mro_amt" alt="총유지보수액" value="0">
<input type="hidden" name="mon_rental_price" value="0">
<input type="hidden" name="min_sale_price" value="0"> -->

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
				<div class="row">
					<div class="col-6">
	<!-- 그리드 타이틀, 컨트롤 영역 -->
						<div class="title-wrap mt10">
							<h4>조회결과</h4>
							<div class="btn-group">
								<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
								</div>
							</div>
						</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
						<div  id="auiGrid"  style="margin-top: 5px; height: 300px;"></div>
<!-- /조회결과 -->
					</div>
					<div class="col-6">
						<div class="title-wrap mt10">
							<h4>상세정보</h4>
						</div>
<!-- 폼 테이블 -->			
						<table class="table-border mt5">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">부품명</th>
									<td>
<!-- 										<select class="form-control"> -->
<!-- 											<option>브레이커-BRK</option> -->
<!-- 										</select> -->
										<div class="input-group">
											<input type="text" class="form-control border-right-0" id="part_name" name="part_name" readonly="readonly">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchPart();" id="partSearchbtn">
												<i class="material-iconssearch"></i>
											</button>
											<input type="hidden" id="part_no" name="part_no" value="" required="required">
										</div>
									</td>
									<th class="text-right"></th>
									<td>
										<%-- <select class="form-control" id="machine_plant_seq" name="machine_plant_seq">
											<c:forEach items="${list}" var="item">
												<option value="${item.machine_plant_seq}">${item.machine_name}</option>
											</c:forEach>
										</select> --%>
									</td>			
								</tr>
								<tr>
									<th class="text-right rs">어태치먼트명</th>
									<td>
										<input type="text" class="form-control rb" id="attach_name" name="attach_name">
									</td>
									<th class="text-right rs">기종/규격</th>
									<td>
										<div class="row">
											<select class="form-control ml5 mr5" style="width: 45%;"  name="machine_type_cd" id="machine_type_cd" onchange="fnChangeMachine();" required="required" alt="장비기종">
												<c:forEach var="item" items="${codeMap['MACHINE_TYPE']}">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:forEach>
											</select>
											<input class="form-control" style="width: 45%;" type="text" id="machine_sub_type_cd" name="machine_sub_type_cd" easyui="combogrid" alt="장비규격"
												   easyuiname="list" panelwidth="150" idfield="code" textfield="code_name" multi="Y" required="required"/>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">취득세율</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width60px">
												<input type="text" class="form-control text-right formula" format="decimal" required="required" id="reg_tax_rate" name="reg_tax_rate" alt="취득세율">
											</div>
											<div class="col width16px">%</div>
										</div>
									</td>
									<th class="text-right">취득세</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly required="required" id="reg_tax_amt" name="reg_tax_amt" alt="취득세">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
								</tr>	
								<tr>
									<th class="text-right">이자율</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width60px">
												<input type="text" class="form-control text-right formula" format="decimal" required="required" id="interest_rate" name="interest_rate" alt="이자율">
											</div>
											<div class="col width16px">%</div>
										</div>
									</td>
									<th class="text-right">이자율적용</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly required="required" id="interest_amt" name="interest_amt" alt="이자율적용">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
								</tr>	
								<tr>
									<th class="text-right">구매가격</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right formula" format="num" required="required" id="buy_price" name="buy_price" alt="구매가격">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
									<th class="text-right">어태치가액</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly required="required" id="attach_price" name="attach_price" alt="장비가액">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
								</tr>		
								<tr>
									<th class="text-right">연간유지보수액</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" required="required" id="year_mro_amt" name="year_mro_amt" alt="연간유지보수액" readonly="readonly" value="0">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
									<th class="text-right">기본여부</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio"
												name="base_yn" id="base_yn_y" value="Y"> 
												<label for="base_yn_y" class="form-check-label">Y</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio"
												name="base_yn" id="base_yn_n" value="N" checked="checked">
											<label for="base_yn_n" class="form-check-label">N</label>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">유무상여부</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio"
												   name="cost_yn" id="cost_yn_y" value="Y">
											<label for="cost_yn_y" class="form-check-label">Y</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio"
												   name="cost_yn" id="cost_yn_n" value="N" checked="checked">
											<label for="cost_yn_n" class="form-check-label">N</label>
										</div>
									</td>
									<th class="text-right">사용여부</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio"
												   name="use_yn" id="use_yn_y" value="Y" checked="checked">
											<label for="use_yn_y" class="form-check-label">Y</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio"
												   name="use_yn" id="use_yn_n" value="N">
											<label for="use_yn_n" class="form-check-label">N</label>
										</div>
									</td>
								</tr>
							</tbody>
						</table>			
<!-- /폼 테이블 -->	
<!-- /조회결과 -->							
					</div>
				</div>										
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
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>