<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈비용 > 렌탈기준정보-장비 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
-- 주의사항 : 기준정보의 가동률은 렌탈비 산정할때 들어가는 가동률(직접입력)이고,
-- 렌탈장비대장상세에 가동률은 매출에 따라 달라지는 가동률이다(렌탈비산정에 안들어가는 가동률임)
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			// 취득세율, 이자율, 장비가(대리점가) 입력시 계산
			$(".formula").each(function() {
				$(this).change(function(event){
					if("" == $M.getValue("machine_plant_seq")) {
// 						fnNew();
						alert("모델을 선택해 주세요.");
						return false;
					} else {
						fnFormula();
					}
				});
			});
		});
	
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
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "85", 
					minWidth : "75",
					style : "aui-center",
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
					filter : {
						showIcon : true
					}
				},
	
				{
					headerText : "장비가",
					dataField : "agency_price", 		
					width : "85", 
					minWidth : "75",
					style : "aui-right",
					dataType : "numeric",
					filter : {
						showIcon : true
					}
				},			
				{
					dataField : "machine_plant_seq", 
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "machine_name" ) {
					fnNew();
					goDetail(event.item.machine_plant_seq);
				}
			});
			
		}
		
		function enter(fieldObj) {
			var field = ["s_machine_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(true);
				};
			});
		}
		
		// 목록조회
		function goSearch(isNewSetting) {
			var param = {
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_machine_name" : $M.getValue("s_machine_name")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
            
            if(isNewSetting) {
						  fnNew();
            }
					}
				}
			);
		}
		
		// 상세조회
		function goDetail(machine_plant_seq) {
			console.log(machine_plant_seq);
			$M.goNextPageAjax(this_page + "/search/" + machine_plant_seq, null, {method : 'get'},
				function(result) {
					if(result.success) {
						fnSetDetail(result.item);
					}
				}
			);
		}
	
		// 신규 (폼 초기화)
		function fnNew() {
			// 모델조회 버튼 활성화
			$("#machineSearchbtn").prop("disabled", false);
			$M.clearValue({field:[
				"maker_name"
				, "machine_name"
				, "machine_plant_seq"
				, "reg_tax_rate"
				, "reg_tax_amt"
				, "interest_rate"
				, "interest_amt"
				, "agency_price"
				, "proc_time_month"
				, "proc_time_year"
				, "machine_total_amt"
				, "machine_price"
				, "year_mro_amt"
				, "total_mro_amt"
				, "used_market_price"
				, "used_price"
				, "mon_rental_price"
				, "min_sale_price"
				, "op_rate"
				, "item_share_rate"
				, "contract_share_rate"
				, "out_share_rate"
			]});
		}
		
		// 상세 정보 세팅 (폼 세팅)
		function fnSetDetail(item) {
			// 모델조회 버튼 비활성화
			$("#machineSearchbtn").prop("disabled", true);
			$M.setValue("maker_name", item.maker_name);
			$M.setValue("machine_name", item.machine_name);
			$M.setValue("machine_plant_seq", item.machine_plant_seq);
			$M.setValue("reg_tax_rate", item.reg_tax_rate);
			$M.setValue("reg_tax_amt", item.reg_tax_amt);
			$M.setValue("interest_rate", item.interest_rate);
			$M.setValue("interest_amt", item.interest_amt);
			$M.setValue("agency_price", item.agency_price);
			$M.setValue("proc_time_month", item.proc_time_month || "0");
			$M.setValue("proc_time_year", item.proc_time_year);
			$M.setValue("machine_total_amt", item.machine_total_amt);
			$M.setValue("machine_price", item.machine_price);
			$M.setValue("year_mro_amt", item.year_mro_amt);
			$M.setValue("total_mro_amt", item.total_mro_amt);
			$M.setValue("used_market_price", item.used_market_price);
			$M.setValue("used_price", item.used_price);
			$M.setValue("mon_rental_price", item.mon_rental_price);
			$M.setValue("min_sale_price", item.min_sale_price);
			$M.setValue("op_rate", item.op_rate);
			$M.setValue("item_share_rate", item.item_share_rate);
			$M.setValue("contract_share_rate", item.contract_share_rate);
			$M.setValue("out_share_rate", item.out_share_rate);
		}

		// 저장
		function goSave() {
			var machine_plant_seq = $M.getValue("machine_plant_seq");
			if(machine_plant_seq == "") {
				alert("모델을 선택해 주세요");
				return;
			}

			var itemShareRate = $M.getValue("item_share_rate");
			var contractShareRate = $M.getValue("contract_share_rate");
			var outShareRate = $M.getValue("out_share_rate");
			
			if(itemShareRate == '') {
				alert("렌탈수익배분 안건자의 값이 비어있습니다.")
				return;
			}

			if(contractShareRate == '') {
				alert("렌탈수익배분 계약자의 값이 비어있습니다.")
				return;
			}

			if(outShareRate == '') {
				alert("렌탈수익배분 출고자의 값이 비어있습니다.")
				return;
			}
			
			var totalRate = $M.toNum(itemShareRate) + $M.toNum(contractShareRate) + $M.toNum(outShareRate);
			if (totalRate > 100) {
				alert("수익배분률은 합쳐서 100%를 넘길 수 없습니다.");
				return false;
			}

			if (totalRate < 100) {
				alert("수익배분률을 100%로 맞춰 주시기 바랍니다.");
				return false;
			}

			var frm = document.main_form;
			if($M.validation(frm) == false) { 
				return;
			}
			$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
            goSearch(false);
					}
				}
			);
		}
	
		// 삭제
		function goRemove() {
			var machine_plant_seq = $M.getValue("machine_plant_seq");
			if(machine_plant_seq == "") {
				alert("모델을 선택해 주세요");
				return;
			}
			var param = {
				"machine_plant_seq" : machine_plant_seq
			};
			$M.goNextPageAjaxRemove(this_page + '/remove', $M.toGetParam(param) , {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch(true);
					}
				}
			);
		}
		
		// 엑셀 다운로드
		function fnDownloadExcel() {
			// 제외항목
		 	var exportProps = {};
			fnExportExcel(auiGrid, "렌탈기준정보-장비", exportProps);
		}
		
		// 상세정보 모델조회팝업 선택값 세팅
		function fnSetMachineInfo(data) {
			
			var param = {
				"s_maker_cd" : "",
				"s_machine_plant_seq" : ""
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						var rows = result.list;
						for (var i = 0; i < rows.length; ++i) {
							if (rows[i].machine_plant_seq == data.machine_plant_seq) {
								alert("이미 등록된 장비입니다.");
								return false;
							}
						}
						
						$M.setValue("maker_name", data.maker_name);
						$M.setValue("machine_name", data.machine_name);
						$M.setValue("machine_plant_seq", data.machine_plant_seq);
						// 운영기간
						$M.setValue("proc_time_month", "0");
						$M.setValue("proc_time_year", "0");
					}
				}
			);
		}
		
		// 산식
		function fnFormula() {
			var agency = $M.toNum($M.getValue("agency_price"));
			var taxR = $M.toNum($M.getValue("reg_tax_rate"));
			var taxA = (taxR/100) * agency;
			var iR = $M.toNum($M.getValue("interest_rate"));
			var iA = (iR/100) * agency;
			var mp = agency + iA;
			var param = {
				reg_tax_amt : taxA,
				interest_amt : iA,
				machine_price : mp
			}
			$M.setValue(param);
		}
		
		// 업무DB 연결 함수 21-08-05이강원
     	function openWorkDB(){
     		openWorkDBPanel('', $M.getValue("machine_plant_seq"));
     	}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
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
	<!-- 기본 -->					
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
											<input type="text" class="form-control" id="s_machine_name" name="s_machine_name">
										</div>	
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch(true)">조회</button>
								</td>									
							</tr>						
						</tbody>
					</table>					
				</div>
	<!-- /기본 -->	
				<div class="row">
					<div class="col-6">
	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
						<div class="title-wrap mt10">
							<h4>조회결과</h4>
							<div class="btn-group">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
								</div>
							</div>
						</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
						<div  id="auiGrid"  style="margin-top: 5px; height: 300px;"></div>
					</div>
					<div class="col-6">
<!-- 조회결과 -->
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
									<th class="text-right rs">메이커</th>
									<td>
										<input type="text" class="form-control" readonly="readonly" id="maker_name" name="maker_name">
									</td>
									<th class="text-right rs">모델명</th>
									<td>
										<div class="form-row inline-pd pr">
											<div class="col-auto">
												<div class="input-group">
													<input type="text" class="form-control border-right-0" readonly="readonly" id="machine_name" name="machine_name">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchModelPanel('fnSetMachineInfo', 'N');" id="machineSearchbtn">
														<i class="material-iconssearch"></i>
													</button>
													<input type="hidden" id="machine_plant_seq" name="machine_plant_seq" value="" required="required">
												</div>
											</div>
											<div class="col-auto">
												<button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
											</div>
										</div>
									</td>				
								</tr>
								<tr>
									<th class="text-right rs">취득세율</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width60px">
												<input type="text" class="form-control text-right formula rb" format="decimal" required="required" id="reg_tax_rate" name="reg_tax_rate" alt="취득세율">
											</div>
											<div class="col width16px">%</div>
										</div>
									</td>
									<th class="text-right">취득세</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly="readonly" required="required" id="reg_tax_amt" name="reg_tax_amt" alt="취득세">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
								</tr>	
								<tr>
									<th class="text-right rs">이자율</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width60px">
												<input type="text" class="form-control text-right formula rb" format="decimal" required="required" id="interest_rate" name="interest_rate" alt="이자율">
											</div>
											<div class="col width16px">%</div>
										</div>
									</td>
									<th class="text-right">이자율적용</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly="readonly" required="required" id="interest_amt" name="interest_amt" alt="이자율적용">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
								</tr>	
								<tr>
									<!-- 장비가(대리점가) -> 장비매입가로 변경 -->
									<th class="text-right rs">장비매입가</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right formula rb" format="num" required="required" id="agency_price" name="agency_price" alt="장비매입가">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
									<th class="text-right">장비가액</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly="readonly" required="required" id="machine_price" name="machine_price" alt="장비가액">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
									<!-- <th class="text-right">운영기간</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width50px">
												<input type="text" class="form-control text-right" format="num" readonly="readonly" required="required" id="proc_time_month" name="proc_time_month" alt="운영기간(개월)">
											</div>
											<div class="col width33px">개월</div>
											<div class="col width40px">
												<input type="text" class="form-control text-right" format="decimal" readonly="readonly" required="required" id="proc_time_year" name="proc_time_year" alt="운영기간(년)">
											</div>
											<div class="col width16px">년</div>
										</div>
									</td> -->
								</tr>	
								<tr>
									<!-- <th class="text-right">장비총가액</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly="readonly" required="required" id="machine_total_amt" name="machine_total_amt" alt="장비총가액">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td> -->
								</tr>		
								<tr>
									<th class="text-right">연간유지보수액</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly="readonly" id="year_mro_amt" name="year_mro_amt" alt="연간유지보수액">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
									<!-- 주의사항 : 이 가동률은 렌탈비 산정할때 들어가는 가동률-->
									<!-- 렌탈장비대장상세에 가동률은 매출에 따라 달라지는 가동률이다(렌탈비산정에 안들어가는 가동률임)  -->
									<th class="text-right rs">가동률</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right rb" format="num" required="required" id="op_rate" name="op_rate" alt="가동률" min="0" max="100">
											</div>
											<div class="col width16px">%</div>
										</div>
									</td>
								</tr>
								<tr>
									<!-- <th class="text-right">중고시세</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly="readonly" required="required" id="used_market_price" name="used_market_price" alt="중고시세">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td> -->
									<!-- <th class="text-right">중고최종가</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly="readonly" required="required" id="used_price" name="used_price" alt="중고최종가">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td> -->
								</tr>
								<tr>
									<!-- <th class="text-right">월 렌탈료</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly="readonly" required="required" id="mon_rental_price" name="mon_rental_price" alt="월 렌탈료">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td> -->
									<!-- <th class="text-right">최소판매가</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" format="num" readonly="readonly" required="required" id="min_sale_price" name="min_sale_price" alt="최소판매가">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td> -->
								</tr>
								<tr>
									<th class="text-right">렌탈수익배분</th>
									<td colspan="3">
										<div class="form-row inline-pd widthfix">
											<div class="col width60px text-right">
												안건자
											</div>
											<div class="col width50px text-right">
												<input type="text" class="form-control" format="num" id="item_share_rate" name="item_share_rate" min="0" max="100">
											</div>
											<div class="col width16px">
												%
											</div>
											<div class="col width60px text-right">
												계약자
											</div>
											<div class="col width50px text-right">
												<input type="text" class="form-control" format="num" id="contract_share_rate" name="contract_share_rate" min="0" max="100">
											</div>
											<div class="col width16px">
												%
											</div>
											<div class="col width60px text-right">
												출고자
											</div>
											<div class="col width50px text-right">
												<input type="text" class="form-control" format="num" id="out_share_rate" name="out_share_rate" min="0" max="100">
											</div>
											<div class="col width16px">
												%
											</div>
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